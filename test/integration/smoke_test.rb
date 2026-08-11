require "test_helper"

class SmokeTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = User.create!(email: "smoke_admin@example.com", password: "password123", role: :admin)

    @charity_user = User.create!(email: "smoke_charity@example.com", password: "password123", role: :charity)
    @charity = Charity.create!(user: @charity_user, org_name: "Smoke Charity", region: "Kanto", prefecture: "Tokyo")

    @donor_user = User.create!(email: "smoke_donor@example.com", password: "password123", role: :donor)
    @donor = Donor.create!(user: @donor_user, display_name: "Smoke Donor")

    @req = Request.create!(
      charity: @charity,
      title: "Smoke test request",
      description: "Needed for smoke test",
      condition: "new",
      urgency: "medium",
      quantity_needed: 3
    )

    @offer = Offer.new(
      request: @req,
      donor: @donor,
      quantity_offered: 1,
      condition: "new",
      can_ship_by: Date.tomorrow,
      status: "received"
    )
    @offer.photos.attach(io: StringIO.new("fake"), filename: "photo.jpg", content_type: "image/jpeg")
    @offer.save!

    @notification = OfferRejectedNotification.create!(recipient: @donor, offer: @offer)
  end

  def visit_as(user, path, label)
    sign_out :user
    sign_in user if user
    get path
    m = response.body.match(/<h1>(.*?)<\/h1>/m)
    error = m && m[1]&.strip
    assert response.status < 500 && error != "Unknown action",
      "#{label} (#{path}) as #{user&.email || 'guest'} -> status=#{response.status} error=#{error.inspect}"
  end

  test "every page renders without a 5xx or Unknown action error" do
    pages = [
      ["root", @admin, "/en"],
      ["root", @charity_user, "/en"],
      ["root", @donor_user, "/en"],
      ["admin dashboard", @admin, "/en/admins/dashboard"],
      ["charity dashboard", @charity_user, "/en/charities/dashboard"],
      ["donor dashboard", @donor_user, "/en/donors/dashboard"],

      ["charities index", @admin, "/en/charities"],
      ["donors index", @admin, "/en/donors"],

      ["requests index", @donor_user, "/en/requests"],
      ["request show (charity owner)", @charity_user, "/en/requests/#{@req.id}"],
      ["request show (donor)", @donor_user, "/en/requests/#{@req.id}"],
      ["new request", @charity_user, "/en/requests/new"],
      ["edit request", @charity_user, "/en/requests/#{@req.id}/edit"],

      ["new offer", @donor_user, "/en/requests/#{@req.id}/offers/new"],
      ["request offers", @charity_user, "/en/requests/#{@req.id}/offers"],
      ["offers index", @donor_user, "/en/offers"],
      ["offer show", @donor_user, "/en/offers/#{@offer.id}"],
      ["edit offer", @donor_user, "/en/offers/#{@offer.id}/edit"],
      ["offers search", @donor_user, "/en/offers/search"],

      ["new feedback", @charity_user, "/en/requests/#{@req.id}/feedback/new"],

      ["sign in", nil, "/en/users/sign_in"],
      ["sign up", nil, "/en/users/sign_up"]
    ]

    pages.each { |label, user, path| visit_as(user, path, label) }
  end

  test "japanese locale dashboard pages" do
    visit_as(@donor_user, "/ja/donors/dashboard", "donor dashboard (ja)")
    visit_as(@charity_user, "/ja/charities/dashboard", "charity dashboard (ja)")
  end

  test "notification dismiss works end to end" do
    sign_in @donor_user
    patch "/en/notifications/#{@notification.id}/dismiss", headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
  end

  test "archive request rejects open offers and does not 500" do
    open_offer = Offer.new(
      request: @req, donor: @donor, quantity_offered: 1, condition: "new",
      can_ship_by: Date.tomorrow, status: "submitted"
    )
    open_offer.photos.attach(io: StringIO.new("fake"), filename: "photo.jpg", content_type: "image/jpeg")
    open_offer.save!

    @req.update!(quantity_remaining: 0)
    sign_in @charity_user
    patch "/en/requests/#{@req.id}/archive"
    assert_response :redirect
    assert_equal "rejected", open_offer.reload.status
  end

  test "write actions do not 500" do
    submitted_offer = Offer.new(
      request: @req, donor: @donor, quantity_offered: 1, condition: "new",
      can_ship_by: Date.tomorrow, status: "submitted"
    )
    submitted_offer.photos.attach(io: StringIO.new("fake"), filename: "photo.jpg", content_type: "image/jpeg")
    submitted_offer.save!

    other_charity_user = User.create!(email: "smoke_charity2@example.com", password: "password123", role: :charity)
    other_charity = Charity.create!(user: other_charity_user, org_name: "Smoke Charity 2", region: "Kanto")
    other_donor_user = User.create!(email: "smoke_donor2@example.com", password: "password123", role: :donor)
    other_donor = Donor.create!(user: other_donor_user, display_name: "Smoke Donor 2")

    # requests#create
    sign_in @charity_user
    post "/en/requests", params: { request: {
      title: "New smoke request", description: "desc", condition: "new",
      urgency: "low", quantity_needed: 1
    } }
    assert_response :redirect, "requests#create -> #{response.status}"
    created_request = Request.order(:created_at).last

    # requests#update
    patch "/en/requests/#{created_request.id}", params: { request: { title: "Updated title" } }
    assert_response :redirect, "requests#update -> #{response.status}"

    # offers#create (donor submits an offer)
    sign_in @donor_user
    post "/en/requests/#{@req.id}/offers", params: { offer: {
      quantity_offered: 1, condition: "new", can_ship_by: Date.tomorrow,
      photos: [Rack::Test::UploadedFile.new(StringIO.new("fake"), "image/jpeg", original_filename: "p.jpg")]
    } }
    assert_response :redirect, "offers#create -> #{response.status}"

    # offers#approve / #reject / #mark_received / #mark_as_shipped
    sign_in @charity_user
    patch "/en/offers/#{submitted_offer.id}/approve"
    assert_response :redirect, "offers#approve -> #{response.status}"
    assert_equal "approved", submitted_offer.reload.status

    patch "/en/offers/#{submitted_offer.id}/reject", params: { rejection_reason: "no longer needed" }
    assert_response :redirect, "offers#reject -> #{response.status}"
    assert_equal "rejected", submitted_offer.reload.status

    shipped_offer = Offer.new(
      request: @req, donor: other_donor, quantity_offered: 1, condition: "new",
      can_ship_by: Date.tomorrow, status: "shipped"
    )
    shipped_offer.photos.attach(io: StringIO.new("fake"), filename: "photo.jpg", content_type: "image/jpeg")
    shipped_offer.save!
    patch "/en/offers/#{shipped_offer.id}/mark_received"
    assert_response :redirect, "offers#mark_received -> #{response.status}"

    approved_offer = Offer.new(
      request: @req, donor: other_donor, quantity_offered: 1, condition: "new",
      can_ship_by: Date.tomorrow, status: "approved"
    )
    approved_offer.photos.attach(io: StringIO.new("fake"), filename: "photo.jpg", content_type: "image/jpeg")
    approved_offer.save!
    sign_in other_donor_user
    patch "/en/offers/#{approved_offer.id}", params: {
      offer: { tracking_number: "TRACK123", estimated_arrival: Date.tomorrow }
    }
    assert_response :redirect, "offers#mark_as_shipped(update) -> #{response.status}"

    # offers#destroy
    destroyable_offer = Offer.new(
      request: @req, donor: @donor, quantity_offered: 1, condition: "new",
      can_ship_by: Date.tomorrow, status: "submitted"
    )
    destroyable_offer.photos.attach(io: StringIO.new("fake"), filename: "photo.jpg", content_type: "image/jpeg")
    destroyable_offer.save!
    sign_in @donor_user
    delete "/en/offers/#{destroyable_offer.id}"
    assert_response :redirect, "offers#destroy -> #{response.status}"

    # feedbacks#create
    sign_in @charity_user
    post "/en/requests/#{@req.id}/feedback", params: { feedback: { comment: "great" } }
    assert_response :redirect, "feedbacks#create -> #{response.status}"

    # charities#approve / #destroy
    sign_in @admin
    patch "/en/charities/#{other_charity.id}/approve"
    assert_response :redirect, "charities#approve -> #{response.status}"

    # donors#approve
    patch "/en/donors/#{other_donor.id}/approve"
    assert_response :redirect, "donors#approve -> #{response.status}"

    delete "/en/charities/#{other_charity.id}"
    assert_response :redirect, "charities#destroy -> #{response.status}"

    delete "/en/donors/#{other_donor.id}"
    assert_response :redirect, "donors#destroy -> #{response.status}"

    # requests#destroy
    sign_in @charity_user
    delete "/en/requests/#{created_request.id}"
    assert_response :redirect, "requests#destroy -> #{response.status}"
  end
end
