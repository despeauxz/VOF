require "rails_helper"

RSpec.describe PitchController, type: :controller do
  let(:user) { create :user }

  before(:each) do
    stub_current_user(:user)
    session[:current_user_info] = user.user_info
    controller.helpers.stub(:admin?) { true }
    @bootcamper = create_list(:bootcamper, 10)
    @cycle_center = create(:cycle_center, :start_today)
    @learner = @bootcamper.map do |camper|
      create(
        :learner_program,
        camper_id: camper.camper_id,
        cycle_center_id: @cycle_center.cycle_center_id
      )
    end
    @valid_params = {
      cycle_center_id: @cycle_center.cycle_center_id,
      demo_date: Date.tomorrow
    }

    @pitch = create(
      :pitch,
      cycle_center_id: @cycle_center.id,
      demo_date: Date.tomorrow,
      created_by: user.user_info[:email]
    )

    @rating = create(:rating)

    @required_rating_params = {
      "ui_ux": 5,
      "api_functionality": 3,
      "error_handling": 3,
      "project_understanding": 5,
      "presentational_skill": 4,
      "decision": "Yes",
      "comment": "okay",
      "rating_id": @rating.id
    }
  end

  describe "POST #create" do
    it " creates a pitch" do
      post :create, params: @valid_params

      expect(response).to have_http_status(:success)
      expect(response.body).to include "Pitch successfully created"
    end
  end

  describe "PUT #update" do
    it "update a pitch" do
      put :update, params: {
        id: @pitch.id,
        demo_date: Date.tomorrow,
        cycle_center_id: @cycle_center.cycle_center_id,
        lfa_email: ["new.panelist@andela.com"],
        camper_id: @learner.map(&:camper_id),
        program_id: 4,
        updates: {
          program: false,
          cycle_center: false,
          added_panelists: [],
          removed_panelists: [],
          demo_date: false
        },
        center_name: "Lagos",
        cycle_number: 45
      }
      expect(response).to have_http_status(:success)
      expect(response.body).to include "Pitch successfully updated"
    end

    it "updates ratings by admin" do
      put :edit_rating, params: @required_rating_params
      expect(response.body).to_not be_empty
    end
  end

  describe "Throws an exeception" do
    before do
      controller.helpers.stub(:admin?) { false }
    end

    it "throws an exception if not admin" do
      put :edit_rating, params: @required_rating_params
      expect(response.body).to_not be_empty
    end
  end
end
