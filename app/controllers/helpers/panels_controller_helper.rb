module PanelsControllerHelper
  def send_invitation_mail(emails_list, pitch_link, pitch, pitch_cycle)
    emails_list.each do |email|
      PitchInvitationMailer.
        invite_panelist_to_a_pitch(
          email, pitch_link, pitch, pitch_cycle
        ).deliver_now
    end
  end

  def set_invite_link(pitch_id, _pitch_cycle_program)
    base_path = "#{request.protocol}#{request.host_with_port}"
    href = "/pitch/#{pitch_id}/panels"
    base_path + href
  end

  def invite_pitch_panelist(lfa_email, pitch, cycle_center_id)
    pitch_cycle =
      CycleCenter.where(cycle_center_id: cycle_center_id).
      includes(%i(center cycle)).
      pluck(:'centers.name', :'cycles.cycle', :program_id).
      map do |name, cycle, program_id|
        { name: name, cycle: cycle, program_id: program_id }
      end
    pitch_link = set_invite_link(pitch.id, pitch_cycle[0][:program_id])
    send_invitation_mail(lfa_email, pitch_link, pitch, pitch_cycle)
  end

  def add_panelists_to_panel(pitch, cycle_center_id)
    unless params[:panelists][:addedPanelists].blank?
      panelists = params[:panelists][:addedPanelists]
      panelists.each do |panelist|
        @panel.panelists.create(email: panelist, accepted: "False")
      end
      invite_pitch_panelist(panelists, pitch, cycle_center_id)
    end
  end

  def remove_panelists_from_panel
    unless params[:panelists][:removedPanelists].blank?
      panelists = params[:panelists][:removedPanelists]
      panelists.each do |panelist|
        lfa = Panelist.find_by(email: panelist, panel_id: @panel.id)
        lfa.destroy if lfa.present?
      end
    end
  end

  def add_learners_to_panel
    unless params[:learners][:addedLearners].blank?
      learners = params[:learners][:addedLearners]
      learners.each { |id| @panel.learners_panels.create(camper_id: id) }
    end
  end

  def remove_learners_from_panel
    unless params[:learners][:removedLearners].blank?
      learners = params[:learners][:removedLearners]
      learners.each do |learner|
        removed_learner = @panel.learners_panels.find_by(camper_id: learner)
        removed_learner.destroy if removed_learner.present?
      end
    end
  end

  def learner_ratings_params(params, panelist_id)
    {
      ui_ux: params[:uiUx].to_i,
      api_functionality: params[:apiFunctionality].to_i,
      error_handling: params[:errorHandling].to_i,
      project_understanding: params[:projectUnderstanding].to_i,
      presentational_skill: params[:presentationalSkill].to_i,
      decision: params[:decision],
      comment: params[:comment],
      learners_panel_id: params[:learnerId].to_i,
      panelist_id: panelist_id
    }
  end

  def user_email
    @user_email ||= session[:current_user_info][:email]
  end

  def fetch_panels(pitch, is_admin, is_panelist)
    @panels = return_appropriate_panels(pitch, is_admin, is_panelist)
    @is_past_pitch = past_pitch?(pitch)
    prepare_panels(@panels) unless @panels.nil?
  end

  def return_appropriate_panels(pitch, is_admin, is_panelist)
    return pitch.panels.order("created_at DESC") if is_admin

    if is_panelist
      panelists = Panelist.where(email: user_email)
      panelists.map do |p|
        p.panel panelists if p.panel.pitch_id == pitch.id
      end.compact
    end
  end

  def get_camper_details(learners_panels)
    learners_panels.map do |learners_panel|
      @is_rated = Rating.where(
        learners_panel_id: learners_panel.id, panelist_id: @logged_panelist
      ).any?
      {
        id: learners_panel.id,
        first_name: learners_panel&.bootcamper&.first_name,
        last_name: learners_panel&.bootcamper&.last_name,
        email: learners_panel&.bootcamper&.email,
        created_at: learners_panel.created_at,
        is_graded: learners_panel.graded?,
        is_rated: @is_rated
      }
    end
  end

  def prepare_panels(panels)
    page_no = params[:page].nil? ? 1 : params[:page]
    page_size = params[:size].nil? ? 14 : params[:size]
    paginated_data = Kaminari.paginate_array(panels).
                     page(page_no).
                     per(page_size)
    data = paginated_data
    {
      admin: helpers.admin?,
      panelist: helpers.pitch_panelist?,
      paginated_data: data,
      total_pages: data.total_pages,
      current_page: data.current_page,
      data_count: data.total_count,
      is_past_pitch: @is_past_pitch
    }
  end

  def filter_average_ratings(data)
    name = params[:filterParams].to_s.split(" ")
    data.select do |_key, value|
      name.all? do |i|
        value[:first_name].downcase.include?(i) ||
          value[:last_name].downcase.include?(i)
      end
    end
  end

  def fetch_learners_average_ratings(average_ratings)
    if params[:filterParams].present?
      @filtered_average_ratings = filter_average_ratings(average_ratings)
      prepare_panels(@filtered_average_ratings)
    else
      prepare_panels(average_ratings)
    end
  end

  def past_pitch?(pitch)
    pitch.demo_date < Date.today
  end
end
