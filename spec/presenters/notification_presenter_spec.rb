require "rails_helper"

RSpec.describe NotificationPresenter, type: :presenter do
  include ActionView::TestCase::Behavior
  let!(:notification_group) { create(:notification_group) }
  let!(:notifications_message) do
    create(:notifications_message,
           notification_group_id: notification_group.id)
  end
  let!(:notification) do
    create(
      :notification,
      notifications_message_id: notifications_message.id
  )
  end
  subject { described_class.new notification, view }
  it "#day_text" do
    expect(subject.day_text).to eq("Today")
  end
  it "#time" do
    expect(subject.time).
      to eq notification.created_at.localtime.strftime("%I:%M %p")
  end
end
