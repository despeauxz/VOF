require "rails_helper"

RSpec.describe LearnersPanel, type: :model do
  describe "Association" do
    it { should belong_to(:bootcamper) }
    it { should belong_to(:panel) }
    it { should have_many(:ratings) }
  end
  describe "Validations" do
    it { validate_presence_of(:panel_id) }
    it { validate_presence_of(:camper_id) }
  end
end
