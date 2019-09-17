require "rails_helper"
require "helpers/main_helper_spec"

RSpec.describe ScheduleFeedback, type: :model do
  include MainHelperSpec
  describe "schedule feedback test cases" do
    it { is_expected.to belong_to(:nps_question) }
    it { is_expected.to belong_to(:cycle_center) }
  end

  describe "validations" do
    it {
      validate_presence_of_attributes(%i(
                                        cycle_center_id
                                        start_date
                                        end_date
                                        program_id
                                        nps_question_id
                                      ))
    }
  end
end
