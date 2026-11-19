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

  test "locked? is true only while a non-rejected offer exists" do
    request = create_request(quantity_needed: 5)
    assert_not request.locked?

    offer = create_offer(request, status: "submitted")
    assert request.locked?

    offer.update_columns(status: "rejected")
    assert_not request.locked?
  end

  test "a locked request rejects changes to locked fields" do
    request = create_request(quantity_needed: 5)
    create_offer(request)

    assert_not request.update(title: "Something else")
    assert request.errors.of_kind?(:title, :locked)

    request.reload
    assert_not request.update(category: ["hygiene"])
    assert request.errors.of_kind?(:category, :locked)
  end

  test "a locked request allows urgency changes and quantity increases only" do
    request = create_request(quantity_needed: 5)
    create_offer(request)

    assert request.update(urgency: "urgent")
    assert request.update(quantity_needed: 8)

    assert_not request.update(quantity_needed: 6)
    assert request.errors.of_kind?(:quantity_needed, :cannot_decrease_while_locked)
  end

  test "an unlocked request can be freely edited" do
    request = create_request(quantity_needed: 5)
    create_offer(request, status: "rejected", rejection_reason: "not needed")

    assert request.update(title: "Something else", quantity_needed: 2)
  end

  private

  def create_request(attrs = {})
    user = User.create!(email: "charity#{SecureRandom.hex(4)}@example.com", password: "password123", role: :charity)
    charity = Charity.create!(user: user, org_name: "Test Charity",
                              address_attributes: { postal_code: "1500001", region: "Kanto", prefecture: "Tokyo",
                                                    city: "Shibuya", street: "1-2-3" })
    Request.create!({
      charity: charity,
      title: "Canned food",
      category: ["food"],
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
