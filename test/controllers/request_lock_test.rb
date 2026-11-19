require "test_helper"

# A request locks once a donor has a live (non-rejected) offer on it, so the
# charity can't change what the donor offered against.
class RequestLockTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @charity_user = User.create!(email: "lock-charity@example.com", password: "password", role: :charity)
    @charity = Charity.create!(user: @charity_user, org_name: "Lock Charity", approved: true,
                               address_attributes: { postal_code: "1500001", region: "Kanto", prefecture: "Tokyo",
                                                     city: "Shibuya", street: "1-2-3" })
    @donor_user = User.create!(email: "lock-donor@example.com", password: "password", role: :donor)
    @donor = Donor.create!(user: @donor_user, display_name: "Lock Donor")
    @other_donor_user = User.create!(email: "lock-other@example.com", password: "password", role: :donor)
    Donor.create!(user: @other_donor_user, display_name: "Other Donor")

    @need = Request.create!(charity: @charity, title: "rice", description: "need rice", condition: "new",
                               urgency: "low", category: ["food"], quantity_needed: 5)
  end

  def create_offer(status: "submitted")
    offer = Offer.new(request: @need, donor: @donor, quantity_offered: 1, condition: "new",
                      can_ship_by: Date.tomorrow, status: status)
    offer.photos.attach(io: StringIO.new("fake"), filename: "photo.jpg", content_type: "image/jpeg")
    offer.save!
    offer
  end

  def update_params(attrs)
    { request: { title: "rice", description: "need rice", condition: "new", urgency: "low",
                 category: ["", "food"], quantity_needed: 5 }.merge(attrs) }
  end

  test "charity can edit any field before an offer exists" do
    sign_in @charity_user

    patch request_path(id: @need.id), params: update_params(title: "beans", quantity_needed: 3)

    assert_equal "beans", @need.reload.title
    assert_equal 3, @need.quantity_needed
  end

  test "a locked update keeps locked fields and applies urgency and quantity increases" do
    create_offer
    sign_in @charity_user

    patch request_path(id: @need.id),
          params: update_params(title: "beans", category: [""], urgency: "urgent", quantity_needed: 7)

    @need.reload
    assert_equal "rice", @need.title
    assert_equal ["food"], @need.category
    assert_equal "urgent", @need.urgency
    assert_equal 7, @need.quantity_needed
  end

  test "a locked update can't lower the quantity" do
    create_offer
    sign_in @charity_user

    patch request_path(id: @need.id), params: update_params(quantity_needed: 2)

    assert_response :unprocessable_entity
    assert_equal 5, @need.reload.quantity_needed
  end

  test "edit page shows the locked notice" do
    create_offer
    sign_in @charity_user

    get edit_request_path(id: @need.id)

    assert_response :success
    assert_match I18n.t("requests.locked_notice"), response.body
  end

  test "request page explains why delete is disabled" do
    create_offer
    sign_in @charity_user

    get request_path(id: @need.id)

    assert_response :success
    assert_match I18n.t("requests.delete_locked"), response.body
  end

  test "charity can't delete a request with a live offer" do
    create_offer
    sign_in @charity_user

    assert_no_difference "Request.count" do
      delete request_path(id: @need.id)
    end
    assert_equal "active", @need.reload.status
  end

  test "deleting a request with only rejected offers archives it instead" do
    offer = create_offer
    offer.update!(status: "rejected", rejection_reason: "no longer needed")
    sign_in @charity_user

    assert_no_difference "Request.count" do
      delete request_path(id: @need.id)
    end
    assert @need.reload.archived?
    assert_equal "no longer needed", offer.reload.rejection_reason
  end

  test "deleting a request with no offers destroys it" do
    sign_in @charity_user

    assert_difference "Request.count", -1 do
      delete request_path(id: @need.id)
    end
  end

  test "an archived request is hidden from the public but open to donors who offered" do
    create_offer(status: "rejected")
    @need.archive!

    sign_in @other_donor_user
    get request_path(id: @need.id)
    assert_response :redirect

    sign_in @donor_user
    get request_path(id: @need.id)
    assert_response :success
  end

  test "charity can reject a submitted offer but not an approved one" do
    submitted = create_offer
    sign_in @charity_user

    assert OfferPolicy.new(@charity_user, submitted).reject?

    submitted.update!(status: "approved")
    assert_not OfferPolicy.new(@charity_user, submitted).reject?

    patch reject_offer_path(id: submitted.id), params: { rejection_reason: "changed my mind" }
    assert_equal "approved", submitted.reload.status
  end

  test "admin can reject an offer at any stage" do
    admin = User.create!(email: "lock-admin@example.com", password: "password", role: :admin)
    offer = create_offer(status: "shipped")

    assert OfferPolicy.new(admin, offer).reject?
  end

  test "charity can't turn off a delivery method a donation in progress uses" do
    create_offer

    @charity.accepts_shipping = false
    assert_not @charity.valid?
    assert @charity.errors.of_kind?(:base, :shipping_in_use)
  end

  test "charity can turn off a delivery method once its donations have arrived" do
    create_offer(status: "received")

    @charity.accepts_shipping = false
    @charity.valid?
    assert_not @charity.errors.of_kind?(:base, :shipping_in_use)
  end

  test "settings disables the shipping switch and says why" do
    create_offer
    sign_in @charity_user

    get settings_path(tab: "location")

    assert_response :success
    assert_match ERB::Util.html_escape(I18n.t("settings.shipping_locked")), response.body
    assert_select "input[type=checkbox][name='charity[accepts_shipping]'][disabled]"
  end

  test "submitting settings with the switch locked leaves shipping on" do
    create_offer
    sign_in @charity_user

    patch settings_path, params: { charity: { accepts_shipping: "0" } }

    assert @charity.reload.accepts_shipping?
  end
end
