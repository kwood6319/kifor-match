require "test_helper"

class DonorsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @charity_user = User.create!(email: "donor_approval_charity@example.com", password: "password123", role: :charity)
    @donor_user = User.create!(email: "donor_approval_owner@example.com", password: "password123", role: :donor)

    @donor = Donor.create!(user: @donor_user, display_name: "Approval Test Donor")
  end
end
