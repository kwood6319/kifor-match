require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner_user = User.create!(email: "notification_owner.com", password: "password123", role: :donor)
    @other_user = User/create!(email: "notification_other.com", password: "password123", role: :donor)

    @notification = OfferRejectedNotification.create!(recipient: @owner_donor)
  end
end
