require "rails_helper"
require "helpers/pitch_helper.rb"
require "helpers/panels_helper_spec.rb"
describe "Panels page" do
  include CreatePitchHelper
  include PanelsHelperSpec
  before :all do
    create_seed_data("rehema.wachira@andela.com")
    create_pitch_with_rated_leaner
  end

  before(:each) do
    panel_setup(stub_admin_panel, stub_current_session_admin_panel)
  end

  after :all do
    clear_seed_data
  end

  feature "Able to view panels" do
    scenario "Displays 1 panels" do
      visit_panels(@pitch.id, @program.name)
      expect(page).to have_css(".panel-card", count: 1)
      expect(page).to have_css(".btn-wrapper")
    end
  end

  feature "no panels created yet" do
    scenario "expect to see Add a new Panel when there is no panel" do
      visit_panels(@pitch.id, @program.name)
      expect(page).to have_content("Add a new Panel")
    end
  end

  feature " Displaying a panel" do
    scenario "Admin can view  panel" do
      visit_panels(@pitch.id, @program.name)
      first(".panel-card").click
      expect(page).to have_content("Learners")
      expect(page).to have_content("Panellists")
      expect(page).to have_content("My Learners")
      find("#ratings-tab").click
      sleep 1
      expect(page).to have_css(".panelist-card__content")
      expect(page).to have_css(".persona-img")
      expect(page).to have_css(".persona-name")
      expect(page).to have_css(".persona-mail")
    end

    scenario "Admin can rate a learner" do
      visit_panels(@pitch.id, @program.name)
      first(".panel-card").click
      find("#ratings-tab").click
      first(".panelist-card__content").click
      find(".continue-btn").click
      page.all(".radio-mark")[1].click
      page.all(".radio-mark")[7].click
      page.all(".radio-mark")[12].click
      page.all(".radio-mark")[17].click
      page.all(".radio-mark")[23].click
      page.execute_script("$('#yes').prop('checked', true)")
      fill_in("comment", with: "Had some good work").click
      find("#learner_rating-container--submit-btn").click
      find("#continue-rating-btn").click
      sleep 2
      expect(current_path).to eq("/pitch/4/panels/3")
    end
  end

  feature "Edit panels" do
    scenario "Admin can edit a panel" do
      visit_panels(@pitch.id, @program.name)
      first(".panel-card .more-icon").hover
      find(".dropdown-item .edit").click
      fill_in("invite-panelist2", with: "test.tester@andela.com")
      find(".add-invitee-icon").click
      find(".submit-panel-btn").click
    end
    scenario "Admin cannot remove a rated learner" do
      visit_panels(@pitch2.id, @program.name)
      first(".panel-card .more-icon").hover
      find(".dropdown-item .edit").click
      find(".selected-learner-close").click
      expect(page).
        to have_content("You cannot remove a rated learner")
    end
  end

  feature "Deleting a panel" do
    scenario "admin should not delete a panel with rated learners" do
      visit_panels(@pitch1.id, @program.name)
      first(".panel-card .more-icon").hover
      find(".dropdown-item.delete").click
      expect(page).to have_content("Confirm Delete")
      find("#confirm-delete-panel").click
      expect(page).
        to have_content("You cannot delete a panel with rated learners")
    end

    scenario "Admin can delete a panel" do
      visit_panels(@pitch.id, @program.name)
      delete_pitch_or_panel("panel", 1)
    end
  end

  feature "no panels created yet" do
    scenario "expect to see Add a new Panel when there is no panel" do
      visit_panels(@pitch.id, @program.name)
      expect(page).to have_content("Add a new Panel")
    end
  end

  feature "Displaying learners ratings summary" do
    scenario "see pitch summary tab" do
      visit_panels(@pitch.id, @program.name)
      find("#summary-tab").click
      expect(page).to have_css("#summary-section")
      expect(page).to have_css(".summary-grid")
    end
  end

  feature "filter learners ratings summary" do
    scenario "see pitch summary tab" do
      visit_panels(@pitch.id, @program.name)
      find("#summary-tab").click
      find(".filter-icon").click
      fill_in("filter-name", with: "uturu")
      find("#filter-button").click
      expect(page).to have_css(".no-data-summary")
    end
  end

  feature "Create panels" do
    scenario "Admin can create a panel" do
      create_panel("panel 1", "test.test@andela.com")
      find(".submit-panel-btn").click
    end
  end

  feature "Preview panels" do
    scenario "Admin can remove a panel from the preview pane" do
      create_panel("Panel 2", "testing.testing@andela.com")
      find(".preview-pane-panel-close").click
      expect(page).to have_content("You have no panels added")
    end
  end

  feature "Edit preview panels" do
    scenario "Admin can edit panel in the preview pane" do
      create_panel("Panel 2", "testing.testing@andela.com")
      find(".panel-card-Panel-2").click
      expect(page).to have_content("Update Panel")
    end
  end
end

describe "Panels page for a panel panelist" do
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

  feature " Displaying a panel" do
    scenario "Admin can view  panel" do
      first(".panel-card").click
      expect(page).to have_content("Demo Ratings")
      expect(page).to have_css(".panelist-cards")
      expect(page).to have_css(".panelist-card")
      expect(page).to have_css(".panelist-card__content")
      expect(page).to have_css(".persona-img")
      expect(page).to have_css(".persona-name")
      expect(page).to have_css(".persona-badge")
    end
  end
end
