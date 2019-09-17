require_relative "panelist_get_all_learners_controller_helper.rb"

module CreatePitchHelper
  def create_seed_data(panelist)
    pitch_create_program_helper
    create_pitch(panelist)
  end

  def create_pitch_past_date
    create_pitch
  end

  def pitch_setup(_user, _session)
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link", text: @program.name).click
    find("img.proceed-btn").click
    visit("/pitch/#{@pitch.id}/panels")
  end

  def panel_setup(_user, _session)
    visit(index_path)
    find("a.dropdown-input").click

    find("ul#index-dropdown li a.dropdown-link", text: @program.name).click
    find("img.proceed-btn").click
    visit(pitch_index_path)

    visit(pitch_panels_path(Pitch.first.id))
  end

  def create_pitch(panelist = "efe.love@andela.com", demo_date = Date.today)
    create_two_pitches(demo_date)
    create_two_panels
    create_three_panelists(panelist)

    @campers[0..2].map do |camper|
      @learners_panel = create(:learners_panel,
                               panel_id: @panel[:id],
                               camper_id: camper[:camper_id])
    end
    @learners_panel1 = create(:learners_panel,
                              panel_id: @panel1.id,
                              camper_id: @campers[0][:camper_id])
    create_list(:rating, 4,
                panelist_id: @panelist1[:id],
                learners_panel_id: @learners_panel1.id)
  end

  def create_two_pitches(demo_date)
    @pitch1 = create(:pitch,
                     cycle_center_id: @cycle_center[:cycle_center_id],
                     demo_date: "2018-07-18",
                     created_by: "juliet@andela.com")
    @pitch = create(:pitch,
                    cycle_center_id: @cycle_center[:cycle_center_id],
                    created_by: "juliet@andela.com",
                    demo_date: demo_date)
  end

  def create_two_panels
    @panel = create(:panel, pitch_id: @pitch.id)
    @panel1 = create(:panel, pitch_id: @pitch1.id)
  end

  def create_three_panelists(panelist)
    @panelist = create(:panelist,
                       panel_id: @panel[:id],
                       email: panelist)
    @panelist1 = create(:panelist,
                        panel_id: @panel1[:id],
                        email: "abu.kama@andela.com")
    @panelist2 = create(:panelist,
                        panel_id: @panel1.id,
                        email: panelist)
    @admin_panelist = create(:panelist,
                             panel_id: @panel1[:id],
                             email: "rehema.wachira@andela.com")
  end

  def clear_seed_data
    Rating.destroy_all
    Pitch.where(
      cycle_center_id: @cycle_center[:cycle_center_id]
    ).destroy_all
    LearnerProgram.where(
      cycle_center_id: @cycle_center[:cycle_center_id]
    ).destroy_all
    @learner_program.destroy
    @cycle_center.destroy
    @campers.map(&:destroy)
    @cycle.destroy
    @center.destroy
    @program.destroy
  end

  def create_new_pitch
    find("#new-pitch-btn").click
    find("#program-select-option").click
    find(".pitch-select-program", text: @program.name).click
    sleep 1
    find("#cycle-select-option").click
    sleep 1
    find(".pitch-select-cycle").click
    find("#next-btn").click
    sleep 1
    find("a.ui-datepicker-next").click
    find("a.ui-state-default", match: :first).click
    find(".submit-next").click
    visit("/pitch")
  end

  def test_learner_modal_contents
    expect(page).to have_css(".learners-rating-modal-content")
    expect(page).to have_css(".learner-dropdown")
    expect(page).to have_css(".learner-header-name")
    expect(page).to have_css(".learner-name")
    expect(page).to have_css(".learner-email")
  end

  def create_multiple_pitches(number)
    number.times do
      create_new_pitch
    end
  end

  def delete_pitch_or_panel(name, count)
    first(".#{name}-card .more-icon").hover
    find(".dropdown-item.delete").click
    expect(page).to have_content("Confirm Delete")
    find("#confirm-delete-#{name}").click
    expect(page).to have_css(".#{name}-card", count: count)
  end

  def create_pitch_with_rated_leaner(demo_date = Date.today)
    @pitch2 = create(:pitch,
                     cycle_center_id: @cycle_center[:cycle_center_id],
                     demo_date: demo_date,
                     created_by: "juliet@andela.com")
    @panel2 = create(:panel, pitch_id: @pitch2.id)
    @learners_panel2 = create(:learners_panel,
                              panel_id: @panel2.id,
                              camper_id: @campers[0][:camper_id])
    create_list(:rating, 4,
                panelist_id: @panelist2[:id],
                learners_panel_id: @learners_panel2.id)
  end
end
