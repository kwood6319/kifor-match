require "test_helper"

class OfferTest < ActiveSupport::TestCase
  test "quantity_offered cannot exceed the request's remaining quantity" do
    request = create_request(quantity_needed: 3)

    offer = Offer.new(
      request: request,
      donor: create_donor,
      quantity_offered: 4,
      condition: "new",
      can_ship_by: Date.tomorrow
    )

    assert_not offer.valid?
    assert_includes offer.errors[:quantity_offered], "Cannot exceed the remaining quantity needed (3)"
  end

  private

  def create_charity
    user = User.create!(email: "charity#{SecureRandom.hex(4)}@example.com", password: "password123", role: :charity)
    Charity.create!(user: user, org_name: "Test Charity", region: "Kanto")
  end

  def create_request(attrs = {})
    Request.create!({
      charity: create_charity,
      title: "Canned food",
      description: "Needed for shelter",
      condition: "new",
      urgency: "medium",
      quantity_needed: 1
    }.merge(attrs))
  end

  def create_donor
    user = User.create!(email: "donor#{SecureRandom.hex(4)}@example.com", password: "password123", role: :donor)
    Donor.create!(user: user, display_name: "Test Donor")
  end


  def create_offer(request, attrs = {})
    offer = Offer.new({
      request: request,
      donor: create_donor,
      quantity_offered: 1,
      condition: "new",
      can_ship_by: Date.tomorrow
    }.merge(attrs))
    offer.photos.attach(io: StringIO.new("fake"), filename: "photo.jpg", content_type: "image/jpeg")
    offer.save!
    offer
  end

end
