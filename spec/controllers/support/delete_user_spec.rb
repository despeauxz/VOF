require "rails_helper"
RSpec.describe SupportController, type: :controller do
  let!(:user) { create(:user) }
  let!(:admin) { create(:user, :admin) }
  let!(:role) { create(:role) }
  let!(:user_role) { create(:user_role, role_id: role.id) }

  describe "DELETE #delete" do
    before do
      stub_current_user(:admin)
      session[:current_user_info] = admin.user_info
    end

    it "deletes a user" do
      delete :destroy, params: { id: user_role.id }
      expect(response).to be_successful
    end

    it "throws error when user role is not available" do
      delete :destroy, params: { id: 100 }
      expect(json_response[:error]).to eq("Sorry, that user does not exist")
    end

    it "only admin can delete user" do
      session[:current_user_info] = user.user_info
      delete :destroy, params: { id: user_role.id }
      expect(response).to redirect_to(index_path)
    end

    it "throws standard error when user is not set" do
      controller.class.skip_before_filter :set_user
      delete :destroy, params: { id: user_role.id }
      expect(json_response[:error]).to eq("An error occurred")
    end
  end
end
