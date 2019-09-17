require "rails_helper"
require "helpers/pitch_helper.rb"

RSpec.describe PitchController, type: :controller do
  include CreatePitchHelper
  let(:admin) { create :user, :admin }
  before(:each) do
    stub_current_user(:admin)
    session[:current_user_info] = admin.user_info
    @cycle_center = create(:cycle_center, :start_today)
    @pitch = create(:pitch,
                    cycle_center_id: @cycle_center[:cycle_center_id],
                    created_by: admin.user_info[:email],
                    demo_date: Date.yesterday)
  end
  describe "DELETE #delete" do
    it "Does not delete a past pitch" do
      delete :destroy, params: {
        id: @pitch.id
      }
      puts response.status
      expect(response).to have_http_status(:success)
      msg = "You cannot delete a pitch whose demo date has passed"
      expect(response.body).to include msg
    end
    it "Does not delete pitch with rated learners" do
      @bootcampers = create_list(:bootcamper, 5)
      @panel = create(:panel, pitch_id: @pitch.id)
      @panelist = create(:panelist,
                         panel_id: @panel[:id],
                         email: "mmm.kenya@andela.com")

      @learners_panel = create(:learners_panel,
                               panel_id: @panel[:id],
                               camper_id: @bootcampers[0][:camper_id])
      create_list(:rating, 4,
                  panelist_id: @panelist[:id],
                  learners_panel_id: @learners_panel.id)
      delete :destroy, params: {
        id: @pitch.id
      }
      expect(response).to have_http_status(:success)
      msg = "You cannot delete a pitch with rated learners"
      expect(response.body).to include msg
    end
  end
end
