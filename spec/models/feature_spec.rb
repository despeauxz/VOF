require "rails_helper"

RSpec.describe Feature, type: :model do
  before(:each) do
    Feature.create!(feature_name: "Test Feature")
  end

  describe "Creation" do
    it "has one feature created" do
      expect(Feature.all.count).to eq(1)
    end
  end

  describe "Association" do
    it { should have_many(:permissions) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:feature_name) }
    it { is_expected.to validate_uniqueness_of(:feature_name).case_insensitive }
  end
end
