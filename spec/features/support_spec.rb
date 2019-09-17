require "rails_helper"
require "helpers/pitch_helper.rb"
require "helpers/support_controller_helper_spec.rb"

describe "View roles" do
  include CreatePitchHelper
  include CreateRolesHelper
  before :all do
    create_seed_data("efe.love@andela.com")
    create_role_seed_data
  end

  before(:each) do
    stub_admin
    stub_current_session_admin
    visit("/")
    find("a.dropdown-input").click
    find("ul#index-dropdown li a.dropdown-link", text: @program.name).click
    find("img.proceed-btn").click
    visit("/support")
    find(".support-card-roles-and-permissions").click
  end

  after :all do
    clear_seed_data
  end

  feature "Admin can View all created roles" do
    scenario "expect to see Added roles" do
      expect(page).to have_content("Set Permissions")
      expect(page).to have_content("View Permissions")
    end
  end

  feature "Admin can View all users" do
    scenario "expect to see a table with all users" do
      page.execute_script "$('.roles-and-permissions-page').hide()"
      page.execute_script "$('.all-users').show()"
      expect(page).to have_css(".roles-and-permission-table")
    end
  end

  feature "Admin can View all created roles" do
    scenario "expect to see Added roles" do
      find(".view-permissions").click
      expect(page).to have_content("Permissions for LFA")
    end
  end

  feature "Admin can assign permissions to a role" do
    scenario "expect a admin to be able to assign roles" do
      find(".set-permissions-btn").click
      expect(page).to have_content("Learners Page")
      find(".permissions-title").click
      find(".radio-mark").click
      expect(page).to have_content("Can Add Learners To Vof")
    end
  end
end
