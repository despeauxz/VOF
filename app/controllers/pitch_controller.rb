class PitchController < ApplicationController
  before_action :get_current_user_email,
                except: %i(create
                           get_learners_cycle
                           get_program_cycle
                           edit
                           update)
  include PitchControllerHelper
  include BootcampersHelper

  def edit_rating
    unless helpers.admin?
      respond_to do |format|
        format.json { render json: "Only admin can edit a learners rating" }
      end
    end
    @new_ratings = Rating.find(params[:rating_id]).
                   update!(edit_pitch_params(params))
    respond_to do |format|
      format.json { render json: @new_ratings }
    end
  end

  def index
    unless helpers.admin? || helpers.pitch_panelist?
      return redirect_to index_path
    end

    @pitches_data = fetch_pitches(helpers.admin?, helpers.pitch_panelist?)
    respond_to do |format|
      format.json { render json: @pitches_data }
      format.html { render template: "pitch/index" }
    end
  end

  def destroy
    @pitch = Pitch.find_by(id: params[:id])

    if helpers.admin?
      delete_pitch
    else
      redirect_to index_path
    end
  rescue ActiveRecord::RecordNotFound => e
    Bugsnag.custom_notify(e)
    render json: { error: "Sorry, the pitch does not exist", status: 404 }
  rescue StandardError => e
    Bugsnag.custom_notify(e)
    render json: { error: "An error occurred", status: 400 }
  end

  def show_learner_ratings
    @rating_details = fetch_learner_ratings
    render json: { rating_details: @rating_details, status: 200 }
  end

  def pitch_setup
    redirect_non_admin
  end

  def create
    pitch_data = pitch_params(params)
    pitch = build_pitch(pitch_data[:pitch])
  rescue StandardError => e
    pitch.destroy
    Bugsnag.custom_notify(e)
    render json: { message: "An error occurred", status: 400 }
  else
    render json: { message: "Pitch successfully created", status: 201 }
  end

  def get_rating_breakdown
    @rating_details = fetch_learner_ratings
    render template: "pitch/pitch_rating_breakdown"
  end

  def edit
    @pitch = Pitch.find(params[:id])
    @ratings = @pitch.ratings
    @panelists = @pitch.panelists

    if Date.today > @pitch.demo_date || @ratings.present?
      flash[:success] = "Rated or Overdue Pitch cannot be edited"
      return redirect_to action: :index
    end

    cycle_center = get_pitch_cycle_center(@pitch.id)
    program_name = Program.find(cycle_center[1]).name
    center_name = Center.find(cycle_center[2]).name
    cycle_number = Cycle.find(cycle_center[3]).cycle
    panelists = @panelists.pluck(:email)
    pitch_details = {
      cycle_center_id: cycle_center[0],
      cycle_number: cycle_number,
      center_name: center_name,
      program_id: cycle_center[1],
      program_name: program_name,
      panelists: panelists,
      demo_date: @pitch.demo_date
    }

    respond_to do |format|
      format.json { render json: pitch_details }
      format.html { render template: "pitch/pitch_setup" }
    end
  end

  def update
    pitch_data = pitch_params(params)
    update_cycle_center_program(pitch_data)
    update_pitch_cycle_center(pitch_data)
    update_pitch_date(pitch_data)
  rescue StandardError
    render json: { message: "An error occurred", status: 400 }
  else
    render json: { message: "Pitch successfully updated", status: 200 }
  end

  def get_learners_cycle
    bootcampers_ids = LearnerProgram.active.
                      where("cycle_center_id = ?
                        AND decision_one = ?",
                            params[:cycle_center_id], "Advanced").
                      pluck(:camper_id)

    render json: { data: bootcampers_ids, status: 200 }
  end

  def get_program_cycle
    cycle_center_ids =
      LearnerProgram.active.where("program_id = ? AND decision_one = ?",
                                  params[:program_id], "Advanced").
      pluck(:cycle_center_id).uniq

    cycles_centers = cycle_center_ids.map do |cycle_center_id|
      CycleCenter.active.where("cycle_center_id = ?", cycle_center_id).
        includes(%i(center cycle)).
        pluck(:'centers.name', :'cycles.cycle').
        map do |name, cycle|
        { cycle_center_id: cycle_center_id, name: name, cycle: cycle }
      end
    end
    render json: { centers: cycles_centers.flatten, status: 200 }
  end

  def submit_learner_ratings
    panelist_id = Panelist.find_by(email: @user_email).id
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
                   id: params[:pitchId] }
  end

  def accept_pitch_invite
    return display_pitch_learners if andelan?(@user_email)

    redirect_to logout_path
  end

  private

  def delete_pitch
    if @pitch.ratings.any?
      render json: {
        error: "You cannot delete a pitch with rated learners",
        status: 400
      }
    elsif @user_email != @pitch[:created_by]
      render json: {
        error: "You cannot delete a pitch you haven't created",
        status: 400
      }
    elsif check_overdue_pitch(@pitch.demo_date)
      render json: {
        error: "You cannot delete a pitch whose demo date has passed",
        status: 400
      }
    else
      @pitch.destroy
      render json: { message: "Pitch successfully deleted", status: 200 }
    end
  end

  def get_current_user_email
    @user_email = session[:current_user_info][:email]
  end

  def send_response
    flash[:success] = "Thank you for accepting the invitation"
  end

  def fetch_center_details
    pitch = Pitch.find_by(id: params[:pitch_id])
    @center_details =
      CycleCenter.where(cycle_center_id: pitch[:cycle_center_id]).
      includes(%i(center cycle)).
      pluck(:'centers.name', :'cycles.cycle').flatten
  end

  def get_pitch_panellist(email)
    panelist = Panelist.find_by(
      email: email, pitch_id: params[:pitch_id]
    )
    return display_pitch_learners(panelist) unless panelist.blank?

    redirect_to not_found_path
  end
end
