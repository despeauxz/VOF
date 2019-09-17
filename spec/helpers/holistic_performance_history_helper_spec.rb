require "rails_helper"
require_relative "main_helper_spec.rb"

RSpec.describe HolisticPerformanceHistoryHelper, type: :helper do
  include MainHelperSpec

  let(:user) { create :user }
  let(:inactive_cycle_center) do
    create(:cycle_center, start_date: Date.parse("2018-4-18"),
                          end_date: Date.parse("2018-4-25"))
  end
  let(:cycle_center_in_grace) do
    create(:cycle_center, start_date: 1.week.ago,
                          end_date: Date.yesterday)
  end

  describe "Editing When the bootcamp has ended" do
    context "when an admin user" do
      it "returns false if period has elapsed" do
        validate_for_admin_user(inactive_cycle_center, false)
      end

      it "returns true if it is still in progress" do
        validate_for_admin_user(cycle_center_in_grace, true)
      end
    end
    context "for lfa user" do
      it "returns true if still in progress" do
        allow_any_instance_of(ApplicationHelper).to receive(
          :user_is_lfa?
        ).and_return true

        allow_any_instance_of(ApplicationHelper).to receive(
          :admin?
        ).and_return false
        expect(can_edit_scores?(user.user_info[:id],
                                cycle_center_in_grace.id)).to be true
      end
    end
  end
end
