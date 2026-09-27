require "test_helper"

class OffersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @owner_user = User.create!(email: "offer_owner@example.com", password: "password123", role: :donor)
    @other_user = User.create!(email: "other_owner@example.com", password: "password123", role: :donor)

    @owner_donor = Donor.create!(user: @owner_user, display_name: "Offer Owner")
    @other_donor = Donor.create!(user: @other_user, display_name: "Other Donor")

    charity_user = User.create!(email: "offer_charity@example.com", password: "password123", role: :charity)
    @charity = Charity.create!(user: charity_user, org_name: "Test Charity", region: "Kanto")

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

  test "another donor cannot view the offer" do
    sign_in @other_user
    get offer_path(id: @offer.id, locale: :en)
    assert_redirected_to root_path
  end
end
