require "rails_helper"

RSpec.describe AverageRatings, type: :model do
  let!(:panel) { create(:panel) }
  let!(:bootcamper) { create(:bootcamper) }
  let!(:learners_panel) do
    create(:learners_panel, panel_id: panel.id, camper_id: bootcamper.id)
  end
  subject { described_class.new }

  it "is valid with valid attributes" do
    subject.panel_id = panel.id
    subject.learners_panel_id = learners_panel.id
    subject.camper_id = bootcamper.id
    subject.first_name = bootcamper.first_name
    subject.last_name = bootcamper.last_name
    subject.avg_ui_ux = 2
    subject.avg_api_functionality = 4
    subject.avg_error_handling = 4
    subject.avg_project_understanding = 5
    subject.avg_presentational_skill = 3
    subject.cumulative_average = 3.5
    expect(subject).to be_valid
  end
end
