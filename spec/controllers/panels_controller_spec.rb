require "rails_helper"
require "helpers/panels_helper_spec"
RSpec.describe PanelsController, type: :controller do
  include PanelsHelperSpec
  let!(:pitch) { create(:pitch) }
  let!(:past_pitch) { create(:pitch, demo_date: 2.days.ago) }
  let!(:panels) { create_list(:panel, 15, pitch_id: pitch.id) }
  let!(:user) { create :user }
  let(:not_user) { create :user, :not_user }
  let!(:panel_one) { panels.first }
  let!(:panel_second) { panels.second }
  let!(:panel_last) { panels.last }
  let!(:panelist) { create(:panelist, panel_id: panel_last.id) }
  let!(:new_panelist) { create(:new_panelist, panel_id: panel_last.id) }
  let!(:learners_panel) { create(:learners_panel, panel_id: panel_last.id) }
  let!(:rating) do
    create(:rating,
           panelist_id: panelist.id,
           learners_panel_id: learners_panel.id)
  end
  let!(:bootcamper) { create(:bootcamper) }
  let!(:panel_params) do
    {
      "pitch_id" => pitch.id,
      "panels" => { "0" =>
        {
          panel_name: "New panel",
          panel_learners: [
            bootcamper.id
          ],
          panellists: ["tes.test@andela.com", "new.test@andela.com"]
        } }
    }
  end
  before do
    stub_current_user(:user)
    session[:current_user_info] = user.user_info
    controller.helpers.stub(:admin?) { true }

    @cycle_center = create(:cycle_center, :start_today)
    @past_pitch = create(:pitch,
                         cycle_center_id: @cycle_center[:cycle_center_id],
                         created_by: user.user_info[:email],
                         demo_date: Date.yesterday)

    @past_panel = create(:panel, pitch: @past_pitch)
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: { pitch_id: pitch.id }
      expect(response).to be_successful
    end

    it "returns paginated response" do
      get :index, params: { pitch_id: pitch.id }
      expect(assigns(:panels)[:paginated_data].count).to eq 14
    end
  end

  describe "SHOW #show" do
    it "redirect to not_found_path if panel not found" do
      get :show, params: { pitch_id: pitch.id, id: 2432 }
      expect(response).to redirect_to(not_found_path)
    end
    context "An andela but not an admin and not a panelist" do
      before(:each) do
        session[:current_user_info][:email] = "efe.faith@andela.com"
        controller.helpers.stub(:admin?) { false }
      end
      it "returns the user to index page" do
        get :show, params: { pitch_id: pitch.id, id: panel_last.id }
        expect(response).to redirect_to(index_path)
      end
    end

    context "A panelist not invited to the panel" do
      before(:each) do
        session[:current_user_info][:email] = "kingsley.eneja@andela.com"
        controller.helpers.stub(:admin?) { false }
        controller.helpers.stub(:pitch_panelist?) { true }
      end
      it "returns the user to index page" do
        get :show, params: { pitch_id: pitch.id, id: panel_last.id }
        expect(response).to redirect_to(index_path)
      end
    end

    context "An Admin with valid params" do
      it "returns a success response" do
        get :show, params: { pitch_id: pitch.id, id: panel_one.id }
        expect(response).to be_successful
      end
      it "renders panels/show template" do
        get :show, params: { pitch_id: pitch.id, id: panel_one.id }
        expect(response).to render_template("panels/show")
      end
    end

    context "A panel panelist with valid params" do
      before(:each) do
        session[:current_user_info][:email] = "test.test@andela.com"
        controller.helpers.stub(:admin?) { false }
        controller.helpers.stub(:pitch_panelist?) { true }
        controller.stub(:user_has_been_invited_to_panel?) { true }
      end
      it "returns a success response" do
        get :show, params: { pitch_id: pitch.id, id: panel_one.id }
        expect(response).to be_successful
      end
      it "renders panels/show template" do
        get :show, params: { pitch_id: pitch.id, id: panel_one.id }
        expect(response).to render_template("panels/show")
      end
    end

    context "A panel panelist with valid params" do
      before(:each) do
        session[:current_user_info][:email] = "test.test@andela.com"
        controller.helpers.stub(:admin?) { false }
        controller.helpers.stub(:pitch_panelist?) { false }
      end

      it "returns the user to index page if not panelist or admin" do
        get :index, params: { pitch_id: pitch.id, id: panel_one.id }
        expect(response).to redirect_to(index_path)
      end
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: { pitch_id: pitch.id }
      expect(response).to be_successful
    end
    it "returns panels template for past pitches" do
      get :new, params: { pitch_id: past_pitch.id }
      expect(response).to redirect_to(pitch_panels_path(past_pitch.id))
    end
    it "renders panels/new template" do
      get :new, params: { pitch_id: pitch.id }
      expect(response).to render_template("panels/new")
    end

    it "renders pitches/ template when pitch id doesnt exist" do
      get :new, params: { pitch_id: 1_000_000 }
      expect(response.body).to include("redirected")
    end
  end

  describe "POST #create" do
    it "returns a success response" do
      post :create, params: panel_params
      expect(response).to be_successful
    end
    it "returns an error with invalid params" do
      post :create, params: { pitch_id: pitch.id }
      expect(json_response[:error]).to eq("An error occurred, try again")
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested panel" do
      delete :destroy, params: { pitch_id: pitch.id, id: panel_one.id }
      expect(response).to be_successful
    end
    it "destroys the requested panel" do
      expect do
        delete :destroy, params: { pitch_id: pitch.id, id: panel_second.id }
      end.to change(Panel, :count).by(-1)
    end
    it "return Panel does not exist if id does not exist" do
      delete :destroy, params: { pitch_id: pitch.id, id: 0 }
      expect(json_response[:error]).to eq("Sorry, the panel does not exist")
    end
    it "Does not delete a panel with learner" do
      delete :destroy, params: { pitch_id: pitch.id, id: panel_last.id }
      expect(json_response[:error]).
        to eq("You cannot delete a panel with rated learners")
    end

    it "redirects to the index_path if not admin" do
      redirect_to_index_path_if_not_admin("destroy", pitch.id, panel_second.id)
    end
  end

  describe "GET #edit" do
    it "gets panel data for update" do
      get :edit, params: { pitch_id: pitch.id, id: panel_one.id }
      expect(response).to be_successful
    end

    it "renders panels/panel_setup template" do
      get :edit, params: { pitch_id: pitch.id, id: panel_one.id }
      expect(response).to render_template("panels/panel_setup")
    end

    it "redirects to the index_path if not admin" do
      redirect_to_index_path_if_not_admin("edit", pitch.id, panel_second.id)
    end

    it "renders json error if overdue demo date" do
      get :edit, params: { pitch_id: @past_pitch.id, id: @past_panel.id }
      expect(json_response[:error]).
        to eq("You cannot edit a panel whose demo date is past")
    end
  end

  describe "PUT #update" do
    it "updates successfully" do
      put :update, params: { pitch_id: pitch.id, id: panel_second.id }
      expect(response).to be_successful
    end

    it "fails to update if params are incorrect" do
      put :update, params: { pitch_id: pitch.id, id: 0 }
      expect(json_response[:error]).to eq("An error occurred")
    end
  end
end
