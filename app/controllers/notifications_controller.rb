class NotificationsController < ApplicationController
  def dismiss
    @notification = current_recipient.notifications.find(params[:id])
    @notification.update!(dismissed: true)
    @notification.offer&.update!(active: false)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  private

  def current_recipient
    current_donor || current_charity
  end
end
