require "test_helper"

class OffersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # SETUP
  setup do
    @owner_user = User.create!(email: "offer_owner@example.com", password: "password123", role: :donor)
    @other_user = User.create!(email: "other_owner@example.com", password: "password123", role: :donor)

    @owner_donor = Donor.create!(user: @owner_user, display_name: "Offer Owner")
    @other_donor = Donor.create!(user: @other_user, display_name: "Other Donor")

    @charity_user = User.create!(email: "offer_charity@example.com", password: "password123", role: :charity)
    @charity = Charity.create!(user: @charity_user, org_name: "Test Charity", region: "Kanto")

    @other_charity_user = User.create!(email: "other_charity@example.com", password: "password123", role: :charity)
    @other_charity = Charity.create!(user: @other_charity_user, org_name: "OtherCharity", region: "Kanto")

    @request = Request.create!(
      charity: @charity, title: "School supplies", description: "Needed supplies",
      condition: "new", urgency: "medium", quantity_needed: 3
    )

    @offer = Offer.new(
      request: @request, donor: @owner_donor, quantity_offered: 1,
      condition: "new", can_ship_by: Date.tomorrow
    )

    @offer.photos.attach(io: StringIO.new("test photo"), filename: "photo.jpg", content_type: "image/jpeg")
    @offer.save!
  end


  #CHECK CROSS-OWNER DONOR-SECURITY
  test "another donor cannot view the offer" do
    sign_in @other_user
    get offer_path(id: @offer.id, locale: :en)
    assert_redirected_to root_path
  end

  test "another donor cannot update the offer" do
    sign_in @other_user
    patch offer_path(id: @offer.id, locale: :en), params: { offer: { quantity_offered: 2 } }
    assert_redirected_to root_path
    assert_equal 1, @offer.reload.quantity_offered
  end

  test "another donor cannot delete the offer" do
    sign_in @other_user
    assert_no_difference "Offer.count" do
      delete offer_path(id: @offer.id, locale: :en)
    end
    assert_redirected_to root_path
    assert @offer.reload.persisted?
  end

  test "another donor cannot mark the offer as shipped" do
    sign_in @other_user
    patch mark_as_shipped_offer_path(id: @offer.id, locale: :en), params: { offer: { tracking_number: "FORGED"} }
    assert_redirected_to root_path
    assert_equal "submitted", @offer.reload.status
    assert_nil @offer.tracking_number
  end

  # CHECK CROSS-OWNER CHARITY SECURITY
  test "another charity cannot approve the offer" do
    sign_in @other_charity_user
    patch approve_offer_path(id: @offer.id, locale: :en)
    assert_redirected_to root_path
    assert_equal "submitted", @offer.reload.status
  end

  test "another charity cannot reject the offer" do
    sign_in @other_charity_user
    patch reject_offer_path(id: @offer.id, locale: :en), params: { rejectiond_reason: "Not ours" }
    assert_redirected_to root_path
    assert_equal "submitted", @offer.reload.status
    assert_nil @offer.rejection_reason
  end

  test "another charity cannot mark the offer as received" do
    sign_in @other_charity_user
    patch mark_received_offer_path(id: @offer.id, locale: :en)
    assert_redirected_to root_path
    assert_equal "submitted", @offer.reload.status
    assert_equal 3, Request.find(@offer.request_id).quantity_remaining
  end

  # CHECK OFFER RECEIVING/SHIPPING FLOW
  test "charity cannot receive an unshipped offer" do
    sign_in @charity_user
    patch mark_received_offer_path(id:@offer.id, locale: :en)
    assert_equal "submitted", @offer.reload.status
    assert_equal 3, Request.find(@offer.request_id).quantity_remaining
  end

  test "donor cannot ship unapproved offer" do
    sign_in @owner_user
    patch mark_as_shipped_offer_path(id: @offer.id, locale: :en), params: { offer: { tracking_number: "TRACK123" } }
    assert_equal "submitted", @offer.reload.status
  end

  test "donor cannot delete a shipped offer" do
    @offer.update!(status: "shipped")
    sign_in @owner_user
    delete offer_path(id: @offer.id, locale: :en)
    assert Offer.exists?(@offer.id)
  end
end
