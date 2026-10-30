require "test_helper"

class AdminFlaggedOffersTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = User.create!(email: "flag-admin@example.com", password: "password", role: :admin)
    @donor_user = User.create!(email: "flag-donor@example.com", password: "password", role: :donor)
    charity_user = User.create!(email: "flag-charity@example.com", password: "password", role: :charity)
    charity = Charity.create!(user: charity_user, org_name: "Test Charity", region: "Kanto",
                              shipping_address: "1-2-3 Test, Tokyo", approved: true)
    @donor = Donor.create!(user: @donor_user, display_name: "Test Donor")
    request_record = Request.create!(charity: charity, title: "Rice", description: "Need rice",
                                     condition: "new", urgency: "low", category: ["food"], quantity_needed: 5)
    @offer = Offer.new(request: request_record, donor: @donor, quantity_offered: 2, condition: "new",
                       can_ship_by: Date.current + 7, status: "flagged", flag_reason: "Items were broken")
    @offer.photos.attach(io: StringIO.new("fake image"), filename: "photo.png", content_type: "image/png")
    @offer.save!
  end

  test "admin resolving a flagged offer completes it" do
    sign_in @admin

    patch resolve_offer_path(id: @offer.id)

    assert_redirected_to admins_dashboard_path
    assert_equal "completed", @offer.reload.status
  end

  test "admin can deactivate the donor" do
    sign_in @admin

    patch deactivate_donor_path(id: @donor.id)

    assert_response :redirect
    assert_not @donor_user.reload.active
  end

  test "donor cannot resolve a flagged offer" do
    sign_in @donor_user

    patch resolve_offer_path(id: @offer.id)

    assert_equal "flagged", @offer.reload.status
  end
end
