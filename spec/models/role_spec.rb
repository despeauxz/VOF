require "rails_helper"

RSpec.describe Role, type: :model do
  describe "Association" do
    it { should have_many(:permissions) }
    it { should have_many(:user_roles) }
  end
  describe "Validations" do
    it { validate_presence_of(:role_name) }
  end
end
