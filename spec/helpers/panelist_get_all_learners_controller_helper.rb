def pitch_create_program
  @program = create(
    :program,
    save_status: true
  )
end

def pitch_create_program_helper
  pitch_create_program
  @center = create(
    :center,
    name: "Lagos",
    country: "Nigeria"
  )
  @cycle = create(:cycle)
  @campers = create_list(:bootcamper, 13)
  @cycle_center = create(
    :cycle_center,
    center_id: @center[:center_id],
    cycle_id: @cycle[:cycle_id],
    program_id: @program[:id],
    end_date: Date.tomorrow
  )
  @campers.map do |camper|
    @learner_program = create(
      :learner_program,
      camper_id: camper[:camper_id],
      cycle_center_id: @cycle_center[:cycle_center_id],
      program_id: @program[:id],
      decision_one: "Advanced"
    )
  end
end

def pitch_panelist_create
  @pitch = create(:pitch,
                  cycle_center_id: @cycle_center[:cycle_center_id])
  @panel = create(:panel, pitch_id: @pitch.id)
  @panelist = create(:panelist,
                     panel_id: @panel.id,
                     email: user.user_info[:email])
  @campers.map do |camper|
    @learners_panel = create(:learners_panel,
                             panel_id: @panel.id,
                             camper_id: camper[:camper_id])
  end
  stub_current_user(:user)
  session[:current_user_info] = user.user_info
end

def pitch_destroy_helper
  @pitch.destroy
  LearnerProgram.where(
    cycle_center_id: @cycle_center[:cycle_center_id]
  ).destroy_all
  @cycle_center.destroy
  @campers.map(&:destroy)
  @cycle.destroy
  @center.destroy
  @program.destroy
end
