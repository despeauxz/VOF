FactoryBot.define do
  factory :notification do
    recipient_email { Faker::Internet.email }
    notifications_message_id { nil }
    is_read { false }
  end
end
