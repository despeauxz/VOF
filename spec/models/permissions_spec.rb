require "rails_helper"

RSpec.describe Permission, type: :model do
  describe "Association" do
    it { should belong_to(:role) }
    it { should belong_to(:feature) }
  end
  describe "Validations" do
    it { is_expected.to validate_presence_of(:feature_id) }
    it { is_expected.to validate_presence_of(:role_id) }
    it { is_expected.to validate_presence_of(:permission_name) }
  end
end
