require "rails_helper"
require "helpers/pitch_helper.rb"

describe "Panelist rate learner page" do
  include CreatePitchHelper
  before :all do
    create_seed_data("efe.love@andela.com")
  end

  before(:each) do
    panel_setup(stub_andelan_panelist, stub_current_session_panelist)
  end

  after :all do
    clear_seed_data
  end

  feature "Able to rate learners" do
    scenario "without filling all fields" do
      visit("/pitch/2/panels/1/1")
      find(".close_modal").click
      fill_in("comment", with: "great work").click
      find("#learner_rating-container--submit-btn").click
      expect(page).to have_content("Kindly fill in the missing fields")
    end

    scenario "filling all fields correctly" do
      visit("/pitch/2/panels/1/1")
      page.all(".radio-mark")[1].click
      page.all(".radio-mark")[7].click
      page.all(".radio-mark")[12].click
      page.all(".radio-mark")[17].click
      page.all(".radio-mark")[23].click
      page.execute_script("$('#yes').prop('checked', true)")
      fill_in("comment", with: "great work").click
      find("#learner_rating-container--submit-btn").click
      find("#continue-rating-btn").click
      sleep 3
      expect(current_path).to eq("/pitch/2/panels/1")
    end
  end
end
