require "rails_helper"
require "helpers/main_helper_spec"

RSpec.describe CurriculaController, type: :controller do
  let!(:bootcamper) { create :bootcamper_with_learner_program }
  let!(:program) { create :program }

  RSpec.configure do |config|
    config.include MainHelperSpec
  end

  describe "GET #index" do
    before do
      stub_current_user(:bootcamper)
      get :index
    end

    it "renders index template" do
      expect(response).to render_template(:index)
    end

    it "returns correct list of all frameworks" do
      list_of_all_frameworks
    end
  end
end
