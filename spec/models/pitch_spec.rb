require "rails_helper"

RSpec.describe Pitch, type: :model do
  describe "Association" do
    it { should have_many(:panels) }
    it { should belong_to(:cycle_center) }
  end
  describe "Validations" do
    it { validate_presence_of(:cycle_center_id) }
    it { validate_presence_of(:demo_date) }
  end
end
