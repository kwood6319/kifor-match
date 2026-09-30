require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner_user = User.create!(email: "notification_owner@example.com", password: "password123", role: :donor)
    @other_user = User.create!(email: "notification_other@example.com", password: "password123", role: :donor)

    @owner_donor = Donor.create!(user: @owner_user, display_name: "Notification Owner")
    @other_donor = Donor.create!(user: @other_user, display_name: "Other donor")

    @notification = OfferRejectedNotification.create!(recipient: @owner_donor)
  end

  test "another donor cannot dismiss the notification" do
    sign_in @other_user
    patch dismiss_notification_path(id: @notification.id, locale: :en)
    assert_response :not_found
    assert_not @notification.reload.dismissed?
  end

  test "recipient can dismiss their notification" do
    sign_in @owner_user
    patch dismiss_notification_path(id: @notification.id, locale: :en)
    assert_response :redirect
    assert @notification.reload.dismissed?
  end
end
