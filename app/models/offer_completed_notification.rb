class OfferCompletedNotification < Notification
  def message
    I18n.t("notifications.offer_completed", title: offer.request.title)
  end

  def link_path
    Rails.application.routes.url_helpers.request_path(id: offer.request_id, locale: I18n.locale)
  end
end
