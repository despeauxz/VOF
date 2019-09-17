module ApplicationControllerHelper
  def send_broadcast(notification_info, message)
    notification_info[:recipient_emails].split(",").each do |email|
      notification = Notification.create!(
        recipient_email: email.strip,
        notifications_message_id: message.as_json["id"],
        is_read: "false"
      )

      ActionCable.server.broadcast(
        "notifications-" + email.strip,
        html: render_notification(
          id: notification.as_json["id"],
          content: notification_info[:content],
          priority: notification_info[:priority],
          group: notification_info[:group],
          created_at: notification.as_json["created_at"],
          is_read: "false"
        )
      )
    end
  end

  def save_learner_notification(notification_info)
    group = NotificationGroup.find_or_create_by(name: notification_info[:group])
    message = NotificationsMessage.create!(
      priority: notification_info[:priority],
      content: notification_info[:content],
      notification_group_id: group.id
    )
    send_broadcast(notification_info, message)
  end

  private

  def render_notification(notification)
    ApplicationController.render(
      partial: "layouts/notification",
      locals: { notification: notification }
    )
  end

  def invited_panelist?(andelan_email)
    panelist = Panelist.includes(:panel, :pitches).where(email: andelan_email)
    pitches = panelist.map(&:pitches).flatten
    return false if pitches.nil?

    active_pitches = pitches.select { |p| p.demo_date >= Date.today }
    panelist.present? && active_pitches.present?
  end

  def redirect_non_andelan
    if cookies["jwt-token"] && !session[:current_user_info][:andelan]
      return redirect_to session[:url] if session[:url]

      redirect_to learner_path
    end
  end

  def redirect_non_admin_andelan
    if cookies["jwt-token"] &&
       !session[:current_user_info][:admin] &&
       !session[:current_user_info][:lfa]
      redirect_to analytics_path
    end
  end

  def redirect_unauthorized_learner
    if cookies["jwt-token"] && !session[:current_user_info][:learner]
      redirect_to index_path
    end
  end

  def record_not_found(error)
    Bugsnag.custom_notify(error)
    render json: error.message, status: 404, plain: "404 Not Found"
  end

  def clear_xhr_flash
    if request.xhr?
      flash.discard
    end
  end
end
