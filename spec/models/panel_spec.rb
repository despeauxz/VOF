require "rails_helper"

RSpec.describe Panel, type: :model do
  describe "Association" do
    it { should belong_to(:pitch) }
    it { should have_many(:panelists) }
    it { should have_many(:learners_panels) }
  end
  describe "Validations" do
    it { validate_presence_of(:pitch_id) }
    it { validate_presence_of(:panel_name) }
  end
  it "can not be created without a name" do
    panel = Panel.new
    expect(panel).to_not be_valid
  end
end
