class PanelsController < ApplicationController
  before_action :set_panel, only: %i(destroy show update)
  include PanelsControllerHelper

  def index
    unless helpers.admin? || helpers.pitch_panelist?
      return redirect_to index_path
    end

    @pitch = Pitch.find_by(id: params[:pitch_id])
    return redirect_to not_found_path if @pitch.blank?

    pitch_panels = @pitch.learners_panel_ids
    learners_ratings = AverageRatings.where(learners_panel_id: pitch_panels)
    @rating_count = learners_ratings.size
    @panels = fetch_panels(@pitch, helpers.admin?, helpers.pitch_panelist?)
    respond_to do |format|
      format.json do
        render json: @panels
      end
      format.html { render template: "panels/index" }
    end
  end

  def summary_ratings
    @pitch = Pitch.find_by(id: params[:pitch_id])
    learners_ratings = AverageRatings.where(
      learners_panel_id: @pitch.learners_panel_ids
    )
    learners_ratings_with_panel = learners_ratings.map do |rating|
      panel_name = Panel.find(rating.panel_id).panel_name
      [panel_name, rating].flatten
    end
    @summary_data = fetch_learners_average_ratings(learners_ratings_with_panel)
    render json:  @summary_data
  end

  def show
    pitch = Pitch.find_by(id: params[:pitch_id])

    return redirect_to not_found_path if pitch.blank? || @panel.nil?
    return redirect_to index_path unless user_has_been_invited_to_panel?

    user_has_accepted_invitation

    @center_details = @panel&.pitch&.cycle_center
    @panelist = @panel.panelists
    @learners_panels = @panel.learners_panels
    @logged_panelist = Panelist.where(email: user_email).pluck(:id)[0]
    @campers_details = get_camper_details(@learners_panels)
    @panel_learners = @campers_details

    respond_to do |format|
      format.json do
        render json: { panel: @panel,
                       campers_details: @campers_details }
      end
      format.html { render template: "panels/show" }
    end
  end

  def edit
    return redirect_to index_path unless helpers.admin?

    @panel = Panel.find_by_id(params[:id])
    return redirect_to not_found_path if @panel.nil?

    if @panel.pitch.demo_date < Date.today
      render json: {
        error: "You cannot edit a panel whose demo date is past",
        status: 400
      }
    else
      @learners = ActiveModelSerializers::SerializableResource.
                  new(@panel.learners_panels)

      @panel_details = {
        panelists: @panel.panelists,
        allPitchPanelists: get_pitch_panelists,
        learners: @learners,
        new_learners: learners_programs
      }
      respond_to do |format|
        format.json { render json: @panel_details }
        format.html { render template: "panels/panel_setup" }
      end
    end
  end

  def update
    pitch = Pitch.find_by(id: params[:pitch_id])
    cycle_center_id = pitch.cycle_center_id
    add_panelists_to_panel(pitch, cycle_center_id)
    remove_panelists_from_panel
    add_learners_to_panel
    remove_learners_from_panel
  rescue StandardError
    render json: { error: "An error occurred", status: 400 }
  else
    render json: { message: "Panel successfully updated", status: 200 }
  end

  def rate_learners
    panelist_id = Panelist.find_by(email: user_email).id
    panellist = fetch_pitch_panellist
    @panellist_visit_status = panellist[0].visited?
    learner = LearnersPanel.find_by(panel_id: params[:panel_id],
                                    id: params[:learner_id])
    return redirect_to not_found_path if learner.blank?

    learner_pitch_details = get_learner_pitch_details
    demo_date = Pitch.find_by_id(params[:pitch_id]).demo_date
    if demo_date != Date.today
      flash[:success] = "You can only rate a learner during the demo"
      return redirect_to :back
    end
    rated = Rating.find_by(
      learners_panel_id: params[:learner_id], panelist_id: panelist_id
    )
    if rated
      flash[:error] = "This learner has already been Rated"
      return redirect_to :back
    end
    panellist[0].update_attribute(:visited, true)
    @first_name = learner_pitch_details[0]
    @last_name = learner_pitch_details[1]
  end

  def submit_learner_ratings
    panelist_id = Panelist.find_by(email: user_email).id
    learner_ratings_data = learner_ratings_params(params,
                                                  panelist_id)
    learner_rating = Rating.create!(learner_ratings_data)
  rescue StandardError => e
    learner_rating.destroy
    Bugsnag.custom_notify(e)
    render json: { message: "An error occurred", status: 400 }
  else
    render json: { message: "Learner successfully rated",
                   status: 201,
                   pitch_id: params[:pitchId],
                   panel_id: params[:panelId] }
  end

  def destroy
    return redirect_to index_path unless helpers.admin?

    delete_panel
  rescue StandardError => e
    Bugsnag.custom_notify(e)
    render json: { error: "An error occurred", status: 400 }
  end

  def new
    return redirect_to index_path unless helpers.admin?

    pitch = Pitch.find_by_id(params[:pitch_id])

    return redirect_to controller: "pitch", action: "index" if pitch.blank?

    return redirect_to pitch_panels_path if past_pitch?(pitch)

    camper_ids = pitch.learners_panels.pluck(:camper_id)
    learner_programs = pitch.learner_programs.
                       where(decision_one: "Advanced").where.not(
                         camper_id: camper_ids
    )
    learner_programs = ActiveModelSerializers::SerializableResource.
                       new(learner_programs)
    panelists = pitch&.panelists

    respond_to do |format|
      format.json do
        render json: { learner_programs: learner_programs,
                       panelists: panelists,
                       panel_names: pitch.panels }
      end
      format.html { render template: "panels/new" }
    end
  end

  def create
    pitch = Pitch.find(params[:pitch_id])
    cycle_center_id = pitch.cycle_center_id
    begin
      params[:panels].each_value do |value|
        @panel = Panel.create(
          panel_name: value[:panel_name],
          pitch_id: pitch.id,
          created_by: user_email
        )

        value[:panel_learners].each do |panel_learner|
          @panel.learners_panels.create(camper_id: panel_learner)
        end
        panelists = value[:panellists]
        panelists.each do |panelist_email|
          @panel.panelists.create(email: panelist_email, accepted: "False")
        end
        invite_pitch_panelist(panelists, pitch, cycle_center_id)
      end
      render json: { message: "Panel(s) successfully created" }, status: 201
    rescue StandardError => e
      Bugsnag.custom_notify(e)
      render json: { error: "An error occurred, try again", status: 400 }
    end
  end

  private

  def fetch_pitch_panellist
    @panel = Panel.find(params[:panel_id])
    @panel.panelists.select { |p| p.email == user_email }
  end

  def get_learner_pitch_details
    LearnersPanel.where(id: params[:learner_id]).
      includes(%i(bootcamper panel)).pluck(
        :'bootcampers.first_name',
        :'bootcampers.last_name'
    ).flatten(1)
  end

  def delete_panel
    if @panel.nil?
      render json: { error: "Sorry, the panel does not exist", status: 404 }
    else
      delete_panel_with_no_ratings
    end
  end

  def learners_programs
    @pitch = @panel.pitch
    @campers_ids = @pitch&.learners_panels&.pluck(:camper_id)
    learner_programs = @pitch&.learner_programs&.
                       where(decision_one: "Advanced")&.where&.
                       not(camper_id: @campers_ids)
    @learner_programs = ActiveModelSerializers::SerializableResource.
                        new(learner_programs)
  end

  def delete_panel_with_no_ratings
    if @panel.ratings.any?
      render json: {
        error: "You cannot delete a panel with rated learners",
        status: 400
      }
    elsif user_email != @panel[:created_by]
      render json: {
        error: "You cannot delete a panel you haven't created",
        status: 400
      }
    else
      @panel.destroy
      render json: { message: "Panel successfully deleted", status: 200 }
    end
  end

  def set_panel
    @panel = Panel.includes(learners_panels: %i(ratings bootcamper)).
             find_by_id(params[:id])
  end

  def user_has_been_invited_to_panel?
    @panel.panelists.where(email: user_email).any? || helpers.admin?
  end

  def user_has_accepted_invitation
    panelist = Panelist.find_by(email: user_email, panel_id: params[:id])
    return unless panelist

    unless panelist[:accepted] == "True"
      panelist.update(accepted: "True")
      flash[:success] = "Thank you for accepting the invitation"
    end
  end

  def get_pitch_panelists
    pitch = Pitch.find_by(id: params[:pitch_id])
    pitch&.panelists&.pluck(:email)
  end
end
