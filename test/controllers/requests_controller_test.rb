require "test_helper"

class RequestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # SETUP
  setup do
    @owner_user = User.create!(email: "rrrequest_owner@example.com", password: "password123", role: :charity)
    @other_user = User.create!(email: "rrrequest_other@example.com", password: "password123", role: :charity)

    @owner_charity = Charity.create!(user: @owner_user, org_name: "Owner Charity", region: "Kanto")
    @other_charity = Charity.create!(user: @other_user, org_name: "Other Charity", region: "Kanto")

    @owned_request = Request.create!(
    charity: @owner_charity, title: "School supplies", description: "Needed supplies",
    condition: "new", urgency: "medium", quantity_needed: 3
    )
  end


  # TEST REQUEST SECURITY
  test "another charity cannot update the request" do
    sign_in @other_user
    patch request_path(id: @owned_request.id, locale: :en), params: { request: { title: "Chnaged by another charity" } }
    assert_redirected_to root_path
    assert_equal "School supplies", @owned_request.reload.title
  end

  test "another charity cannot delete the request" do
    sign_in @other_user
    delete request_path(id: @owned_request.id, locale: :en)
    assert_redirected_to root_path
    assert Request.exists?(@owned_request.id)
  end

  # ARCHIVING
  test "another charity cannot archive the request" do
    @owned_request.update_column(:quantity_remaining, 0)
    sign_in @other_user
    patch archive_request_path(id: @owned_request.id, locale: :en)
    assert_redirected_to root_path
    assert_equal "active", @owned_request.reload.status
  end

  test "owner cannot archinve an unfulfilled request through update" do
    sign_in @owner_user
    patch request_path(id: @owned_request.id, locale: :en), params: { request: { status: "archived" } }
    assert_equal "active", @owned_request.reload.status
  end
end
