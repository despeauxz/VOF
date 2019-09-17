module PitchControllerHelper
  def pitch_params(params)
    {
      pitch: {
        cycle_center_id: params["cycle_center_id"],
        demo_date: params["demo_date"],
        created_by: session[:current_user_info][:email]
      },
      panelist: {
        email: params["lfa_email"]
      },
      learner_pitch: {
        camper_id: params["camper_id"]
      },
      pitch_id: params["pitch_id"],
      program_id: params["program_id"],
      updates: params["updates"],
      center_name: params["center_name"],
      cycle_number: params["cycle_number"]
    }
  end

  def build_pitch(pitch_data)
    Pitch.create!(pitch_data.compact)
  rescue ActiveRecord::RecordInvalid => e
    render json: e.message, status: 400
  end

  def fetch_pitches(is_admin, is_panelist)
    @pitches = pitches_allowed_to_view(is_admin, is_panelist)
    pitches_center =
      @pitches.map do |pitch|
        CycleCenter.where(cycle_center_id: pitch[:cycle_center_id]).
          includes(%i(center cycle)).
          order("cycles_centers.created_at DESC").
          pluck(:cycle_center_id, :'centers.name', :'cycles.cycle').
          map do |cycle_center_id, name, cycle|
          {
            pitch_id: pitch[:id],
            demo_date: pitch[:demo_date],
            cycle_center_id: cycle_center_id,
            name: name,
            cycle: cycle,
            learners_count: pitch.learners_panels.length,
            created: pitch[:created_at],
            overdue: check_overdue_pitch(pitch[:demo_date])
          }
        end.first
      end
    prepare_pitches(pitches_center) if is_admin || is_panelist
  end

  def pitches_allowed_to_view(is_admin, is_panelist)
    if is_admin
      @pitches = Pitch.
                 includes(:panels, :learners_panels).order("demo_date DESC")
    elsif is_panelist
      panelists = Panelist.where(email: @user_email)
      @pitches_id = panelists.map(&:pitches).flatten.pluck(:id)
      @pitches = Pitch.includes(:panels, :learners_panels).
                 where(id: @pitches_id).
                 where("demo_date >= ?", Time.now.to_date).
                 order("created_at DESC")
    end
  end

  def prepare_pitches(data)
    page = params[:page].nil? ? 1 : params[:page]
    size = params[:size].nil? ? 10 : params[:size]
    paginated_data = Kaminari.paginate_array(data).
                     page(page).
                     per(size)
    data = paginated_data
    { admin: helpers.admin?,
      panelist: helpers.pitch_panelist?,
      paginated_data: data,
      total_pages: data.total_pages,
      current_page: data.current_page,
      data_count: data.total_count }
  end

  def check_overdue_pitch(date)
    date < Date.today
  end

  def fetch_learner_ratings
    @learner_details = LearnersPanel.where(id: params[:learner_id]).
                       includes(%i(bootcamper)).
                       pluck(:'bootcampers.first_name',
                             :'bootcampers.last_name',
                             :'bootcampers.email').
                       map do |learner|
      { first_name: learner[0],
        last_name: learner[1],
        email: learner[2] }
    end.first

    @rating_details = {
      ratings: prepare_learner_ratings(params[:learner_id]),
      learner: @learner_details
    }

    if helpers.pitch_panelist?
      @rating_details[:panelist_email] = @user_email
    end

    @rating_details
  end

  def fetch_learners_average_ratings
    @pitch = Pitch.find_by(params[:pitch_id])
    panels_ids = @pitch.panels.pluck(:id)
    @average_ratings = AverageRatings.where(panel_id: panels_ids)
    @average_ratings = @average_ratings.
                       each_with_object([]) { |item, array| array << item }
    prepare_pitches(@average_ratings)
  end

  def prepare_learner_ratings(learners_panel_id)
    @learner_ratings = Rating.where(learners_panel_id: learners_panel_id).
                       pluck(:learners_panel_id, :panelist_id, :ui_ux,
                             :api_functionality, :error_handling,
                             :project_understanding, :presentational_skill,
                             :comment, :decision, :id).
                       map do |rating|
      panelist_email = Panelist.find_by(id: rating[1]).email
      { learners_panel_id: rating[0],
        panelist_id: rating[1],
        ui_ux: rating[2],
        api_functionality: rating[3],
        error_handling: rating[4],
        project_understanding: rating[5],
        presentational_skill: rating[6],
        comment: rating[7],
        decision: rating[8],
        panelist_email: panelist_email,
        id: rating[9] }
    end
  end

  def fetch_pitch_panellist
    @pitch = Pitch.find(params[:pitch_id])
    @pitch.panelists.select { |p| p.email = @user_email }
  end

  def get_learner_pitch_details
    LearnersPanel.where(id: params[:learner_id]).
      includes(%i(bootcamper pitch)).pluck(
        :'bootcampers.first_name',
        :'bootcampers.last_name',
        :'pitches.demo_date'
      ).flatten(1)
  end

  def get_campers_email(campers_detail)
    campers_detail.map do |camper_id|
      Bootcamper.find(camper_id).email
    end
  end

  def send_reschedule_mail(emails_list, pitch_data)
    emails_list.each do |email|
      PitchInvitationMailer.
        notify_rescheduled_pitch(
          email,
          pitch_data[:pitch][:demo_date],
          pitch_data[:center_name],
          pitch_data[:cycle_number]
        ).deliver_now
    end
  end

  def get_pitch_cycle_center(pitch_id)
    CycleCenter.joins(:pitch).
      where("pitches.id = ?", pitch_id).
      pluck(:cycle_center_id, :program_id, :center_id, :cycle_id).
      first
  end

  def update_cycle_center_program(pitch_data)
    if pitch_data[:updates][:program] == "true"
      CycleCenter.find(pitch_data[:pitch][:cycle_center_id]).
        update(program_id: pitch_data[:program_id])
    end
  end

  def update_pitch_cycle_center(pitch_data)
    if pitch_data[:updates][:cycle_center] == "true"
      Pitch.find(pitch_data[:pitch_id]).
        update(cycle_center_id: pitch_data[:pitch][:cycle_center_id])
    end
  end

  def update_pitch_date(pitch_data)
    if pitch_data[:updates][:demo_date] == "true"
      Pitch.find(pitch_data[:pitch_id]).
        update(demo_date: pitch_data[:pitch][:demo_date])
    end
  end

  def edit_pitch_params(params)
    {
      "ui_ux": params[:ui_ux],
      "api_functionality": params[:api_functionality],
      "error_handling": params[:error_handling],
      "project_understanding": params[:project_understanding],
      "presentational_skill": params[:presentational_skill],
      "decision": params[:decision].capitalize,
      "comment": params[:comment]
    }
  end
end
