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

  test "editing an approved offer resubmits it for review" do
    request = create_request(quantity_needed: 10)
    offer = create_offer(request, status: "approved")

    offer.update!(quantity_offered: 2)

    assert_equal "submitted", offer.status
  end

  test "completing an offer creates a completion notification for the donor" do
    request = create_request(quantity_needed: 5)
    offer = create_offer(request, status: "approved")

    assert_difference "OfferCompletedNotification.count", 1 do
      offer.update!(status: "completed")
    end

    notification = OfferCompletedNotification.last
    assert_equal offer.donor, notification.recipient
    assert_equal offer, notification.offer
  end

  test "active is false only for terminal statuses" do
    request = create_request(quantity_needed: 5)

    submitted_offer = create_offer(request, status: "submitted")
    rejected_offer = create_offer(request, status: "rejected")
    completed_offer = create_offer(request, status: "completed")

    assert submitted_offer.active
    assert_not rejected_offer.active
    assert_not completed_offer.active
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
