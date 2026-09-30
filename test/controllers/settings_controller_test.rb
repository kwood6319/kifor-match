require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create!(email: "setting_donor@example.com", password: "password123", role: :donor)
    @donor = Donor.create!(user: @user, display_name: "Settings Donor")
  end
end
