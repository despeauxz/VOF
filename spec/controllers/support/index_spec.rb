require "rails_helper"
RSpec.describe SupportController, type: :controller do
  let(:user) { create :user }
  let(:role) { create :role }
  let(:permission) { create :permission }
  let(:search_params) do
    { search: "" }
  end
  let(:search) do
    get :index, params: search_params, session: {
      current_user_info: {
        learner: false
      }
    }
  end

  let(:role) { create :role }

  let(:user_role) { create :user_role, role_id: role.id }

  describe "GET #index" do
    before do
      stub_current_user(:user)
    end
    context "when no search term is passed" do
      before do
        search
      end

      it "loads all faqs" do
        expect(assigns[:faqs].length).to eq 13
      end

      it "loads all resources" do
        expect(assigns[:resources].length).to eq 1
      end
    end

    context "when a search term is passed" do
      context "when the search term matches any faqs" do
        it "loads the matched faqs " do
          search_params[:search] = "ALC"
          search
          expect(assigns[:faqs].length).to eq 3
        end
      end

      context "when the search term does not match any faqs" do
        it "loads no faqs" do
          search_params[:search] = "Demarcation"
          search
          expect(assigns[:faqs].length).to eq 0
        end
      end
    end
  end

  describe "GET #get_users" do
    before do
      stub_current_user(:user)
      session[:current_user_info] = user.user_info
      session[:current_user_info][:email] = "test.test@andela.com"
      controller.helpers.stub(:admin?) { true }
    end
    it "gets a list of all users" do
      get :get_users
      expect(response.status).to eq(200)
    end

    it "redirects a user who is not admin" do
      controller.helpers.stub(:admin?) { false }
      get :get_users
      expect(response).to redirect_to(index_path)
    end
  end

  describe "Get #role_permissions" do
    before do
      stub_current_user(:user)
      create(:permission)
    end

    it "returns a success response" do
      get :role_permissions, params: { id: role.id }
      expect(response).to be_successful
      expect(json_response[0][:feature]).to eq("LEARNERS_PAGE")
    end

    it "returns an error with invalid params" do
      get :role_permissions, params: { id: 0 }
      expect(response).to have_http_status(400)
      expect(json_response[:error]).to eq("Couldn't find Role with 'id'=0")
    end
  end

  describe "PUT #assign_permisions" do
    before do
      stub_current_user(:user)
    end

    it "assigns permissions to a role" do
      session[:current_user_info] = user.user_info
      controller.helpers.stub(:admin?) { true }
      put :assign_permisions, params: {
        id: role.id, permission_id: permission.id, permission_status: true
      }
      expect(response).to be_successful
    end

    it "fails due to an error for instance user is not admin" do
      put :assign_permisions, params: {
        id: role.id, permission_id: permission.id, permission_status: true
      }
      expect(json_response[:error]).to eq("An error occurred, try again")
    end
  end
end
