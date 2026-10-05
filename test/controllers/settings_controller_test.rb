require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "setting_donor@example.com", password: "password123", role: :donor)
    @donor = Donor.create!(user: @user, display_name: "Settings Donor")

    @charity_user = User.create!(email: "settings_charity@example.com", password: "password123", role: :charity)
    @charity = Charity.create!(user: @charity_user, org_name: "Settings Charity", region: "Kanto")
  end

  test "wrong current password cannot change the account password" do
    sign_in @user
    patch settings_account_path(locale: :en),
    params: { user: { current_password: "wrong", password: "newpassword123", password_confirmation: "newpassword123" } }
    assert_response :unprocessable_entity
    assert @user.reload.valid_passwor?("password123")
  end

  test "correct current password changes the account password" do
    sign_in @user
    patch settings_account_path(locale: :en), params: { user: { current_passowrd: "password123", password_confirmation: "newpassword123" } }
    assert_response :redirect
    assert @user.reload.valid_password?("newpassword123")
  end

  test "donor cannot approve itself through profile settings" do
    sign_in @user
    patch settings_path(locale: :en), params: { donor: { display_name: "Updated Donor", approved: true } }
    assert_response :redirect
    assert_equal "Updated Donor", @donor.reload.display_name
    assert_not @donor.approved?
  end

  test "charity cannot approve itself through profile settings" do
    sign_in @charity_user
    patch settings_path(locale: :en), params: { charity: { org_name: "Updated Charity", approved: true } }
    assert_response :redirect
    assert_equal "Updated Charity", @charity.reload.org_name
    assert_not @charity.approved?
  end

  test "locale update cannot change the user's role" do
    sign_in @user
    patch settings_locale_path(locale: :en), params: { user: { locale: "ja", role: "admin" } }
    assert_response :redirect
    assert_equal "ja", @user.reload.locale
    assert @user.donor?
  end

  test "deactivation disables the account" do
    sign_in @user
    patch settings_deactivate_path(locale: :en)
    assert_response :redirect
    assert_not @user.reload.active?

    post user_session_path(locale: :en), params: { user: { email: @user.email, password: "password123"} }
    get settings_path(locale: :en)
    assert_redirected_to new_user_session_path(locale: :en)
  end

  test "guest cannot view settings" do
    get settings_path(locale: :en)
    assert_redirected_to new_user_session_path(locale: :en)
  end
end
