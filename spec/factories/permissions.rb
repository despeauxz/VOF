FactoryBot.define do
  factory :permission do
    feature
    role
    permission_name { "CAN_ADD_LEARNERS_TO_VOF" }
    permission_status { true }
  end
end
