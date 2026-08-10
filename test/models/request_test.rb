require "test_helper"

class RequestTest < ActiveSupport::TestCase
  test "fully_fulfilled? is true once nothing remains" do
    assert Request.new(quantity_remaining: 0).fully_fulfilled?
    assert Request.new(quantity_remaining: nil).fully_fulfilled?
    assert_not Request.new(quantity_remaining: 1).fully_fulfilled?
  end

  test "archived? reflects the status column" do
    assert Request.new(status: "archived").archived?
    assert_not Request.new(status: "active").archived?
  end

  test "archive! marks the request archived and rejects open offers only" do
    request = create_request(quantity_needed: 5)

    open_offer = create_offer(request, status: "submitted")
    approved_offer = create_offer(request, status: "approved")
    shipped_offer = create_offer(request, status: "shipped")
    received_offer = create_offer(request, status: "received")
    already_rejected_offer = create_offer(request, status: "rejected", rejection_reason: "prior reason")

    request.archive!

    assert_equal "archived", request.reload.status
    assert_equal "rejected", open_offer.reload.status
    assert_equal "rejected", approved_offer.reload.status
    assert_equal "rejected", shipped_offer.reload.status
    assert_equal I18n.t("messages.request_fulfilled_rejection"), open_offer.rejection_reason
    assert_equal "received", received_offer.reload.status
    assert_equal "prior reason", already_rejected_offer.reload.rejection_reason
  end

  private

  def create_request(attrs = {})
    user = User.create!(email: "charity#{SecureRandom.hex(4)}@example.com", password: "password123", role: :charity)
    charity = Charity.create!(user: user, org_name: "Test Charity", region: "Kanto")
    Request.create!({
      charity: charity,
      title: "Canned food",
      description: "Needed for shelter",
      condition: "new",
      urgency: "medium",
      quantity_needed: 1
    }.merge(attrs))
  end

  def create_offer(request, attrs = {})
    user = User.create!(email: "donor#{SecureRandom.hex(4)}@example.com", password: "password123", role: :donor)
    donor = Donor.create!(user: user, display_name: "Test Donor")
    offer = build_offer(request, donor, attrs)
    offer.photos.attach(io: StringIO.new("fake"), filename: "photo.jpg", content_type: "image/jpeg")
    offer.save!
    offer
  end

  def build_offer(request, donor, attrs)
    Offer.new({
      request: request,
      donor: donor,
      quantity_offered: 1,
      condition: "new",
      can_ship_by: Date.tomorrow
    }.merge(attrs))
  end
end
