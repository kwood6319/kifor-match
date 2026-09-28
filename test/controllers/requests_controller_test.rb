require "test_helper"

class RequestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # SETUP
  @owner_user = User.create!(email: "request_owner@example.com", password: "password123", role: :charity)
  @other_user = User.create!(email: "request_other@example.com", password: "password123", role: :charity)

  @owner_charity = Charity.create!(user: @owner_user, org_name: "Owner Charity", region: "Kanto")
  @other_charity = Charity.create!(user: other_user, org_name: "Other Charity", region: "Kanto")

  @owned_request = Request.create!(
    charity: @owner_charity, title: "School supplies", description: "Needed supplies",
    condition: "new", urgency: "medium", quantity_needed: 3
  )
end
