class SurveysChannel < ApplicationCable::Channel
  def subscribed
    if current_cable_user
      stream_from "survey-#{current_cable_user['UserInfo']['email']}"
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
