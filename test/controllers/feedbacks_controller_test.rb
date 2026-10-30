require "test_helper"

class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @charity_user = User.create!(email: "fb-charity@example.com", password: "password", role: :charity)
    @donor_user = User.create!(email: "fb-donor@example.com", password: "password", role: :donor)
    charity = Charity.create!(user: @charity_user, org_name: "Test Charity", region: "Kanto",
                              shipping_address: "1-2-3 Test, Tokyo", approved: true)
    @donor = Donor.create!(user: @donor_user, display_name: "Test Donor")
    @request_record = Request.create!(charity: charity, title: "Rice", description: "Need rice",
                                      condition: "new", urgency: "low", category: ["food"], quantity_needed: 5)
    @offer = Offer.new(request: @request_record, donor: @donor, quantity_offered: 2, condition: "new",
                       can_ship_by: Date.current + 7, status: "received")
    @offer.photos.attach(io: StringIO.new("fake image"), filename: "photo.png", content_type: "image/png")
    @offer.save!
  end

  def feedback_params
    { feedback: { comment: "Thanks" } }
  end

  test "owning charity submitting feedback completes the offer and notifies the donor" do
    sign_in @charity_user

    assert_difference -> { OfferCompletedNotification.where(recipient: @donor).count }, 1 do
      post offer_feedback_path(offer_id: @offer.id), params: feedback_params
    end

    assert_redirected_to request_path(id: @request_record.id)
    assert_equal "completed", @offer.reload.status
    assert_equal "Thanks", @offer.feedback.comment
  end

  test "another user cannot complete the offer via feedback" do
    sign_in @donor_user

    post offer_feedback_path(offer_id: @offer.id), params: feedback_params

    assert_response :redirect
    assert_equal "received", @offer.reload.status
    assert_nil @offer.feedback
  end

  test "escalate flags the offer and saves the reason" do
    sign_in @charity_user
    remaining_before = @request_record.reload.quantity_remaining

    post offer_feedback_path(offer_id: @offer.id),
         params: { feedback: { escalated: "1", comment: "Items were broken" } }

    assert_redirected_to request_path(id: @request_record.id)
    @offer.reload
    assert_equal "flagged", @offer.status
    assert_equal "Items were broken", @offer.flag_reason
    assert @offer.feedback.escalated?
    assert_equal remaining_before, @request_record.reload.quantity_remaining
  end
end
