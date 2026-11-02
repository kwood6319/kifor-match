require "test_helper"

class CharityApprovalTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = User.create!(email: "approval-admin@example.com", password: "password", role: :admin)
    @charity_user = User.create!(email: "approval-charity@example.com", password: "password", role: :charity)
    @charity = Charity.create!(user: @charity_user, org_name: "Pending Charity", region: "Kanto",
                               shipping_address: "1-2-3 Test, Tokyo")
    @donor_user = User.create!(email: "approval-donor@example.com", password: "password", role: :donor)
    @donor = Donor.create!(user: @donor_user, display_name: "Test Donor")
  end

  def request_params
    { request: { title: "Rice", description: "Need rice", condition: "new", urgency: "low",
                 category: ["food"], quantity_needed: 5 } }
  end

  def create_request_for(charity)
    Request.create!(charity: charity, title: "Rice", description: "Need rice",
                    condition: "new", urgency: "low", category: ["food"], quantity_needed: 5)
  end

  test "unapproved charity cannot post a need by going to the URL directly" do
    sign_in @charity_user

    get new_request_path
    assert_redirected_to pending_approval_path

    assert_no_difference "Request.count" do
      post requests_path, params: request_params
    end
    assert_redirected_to pending_approval_path
  end

  test "approved charity can post a need" do
    @charity.update!(approved: true)
    sign_in @charity_user

    assert_difference "Request.count", 1 do
      post requests_path, params: request_params
    end
  end

  test "admin dashboard lists charities awaiting approval" do
    sign_in @admin

    get admins_dashboard_path

    assert_response :success
    assert_match "Pending Charity", response.body
  end

  test "admin can approve a charity" do
    sign_in @admin

    patch approve_charity_path(id: @charity.id)

    assert @charity.reload.approved?
  end

  test "admin can deactivate and reactivate a charity" do
    sign_in @admin

    patch deactivate_charity_path(id: @charity.id)
    assert_not @charity_user.reload.active?

    patch activate_charity_path(id: @charity.id)
    assert @charity_user.reload.active?
  end

  test "non-admin cannot deactivate a charity" do
    sign_in @donor_user

    patch deactivate_charity_path(id: @charity.id)

    assert @charity_user.reload.active?
  end

  test "deactivated charities drop off the pending approval list" do
    @charity_user.update!(active: false)
    sign_in @admin

    get admins_dashboard_path

    assert_no_match "Pending Charity", response.body
  end

  test "donors do not see needs from deactivated charities" do
    @charity.update!(approved: true)
    need = create_request_for(@charity)
    sign_in @donor_user

    get requests_path
    assert_match need.title, response.body

    @charity_user.update!(active: false)

    get requests_path
    assert_no_match need.title, response.body

    get request_path(id: need.id)
    assert_redirected_to root_path
  end

  test "donors cannot donate to a deactivated charity's need" do
    @charity.update!(approved: true)
    need = create_request_for(@charity)
    @charity_user.update!(active: false)
    sign_in @donor_user

    assert_no_difference "Offer.count" do
      post request_offers_path(request_id: need.id), params: { offer: { quantity_offered: 1, condition: "new",
                                                         can_ship_by: Date.current + 7 } }
    end
  end
end
