require "rails_helper"

RSpec.describe UserRole, type: :model do
  describe "Association" do
    it { should belong_to(:role) }
  end
  describe "Validations" do
    it { validate_presence_of(:email) }
  end
end
