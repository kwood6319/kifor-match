require "test_helper"

class CharitiesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @donor_user = User.create!(email: "approval_donor@example.com", password: "password123", role: :donor)
    @charity_user = User.create!(email: "approval_charity@example.com", password: "password123", role: :charity)

    @charity = Charity.create!(user: @charity_user, org_name: "Approval Test Charity", region: "Kanto")
  end
end
