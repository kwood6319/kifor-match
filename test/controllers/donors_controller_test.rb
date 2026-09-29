require "test_helper"

class DonorsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @charity_user = User.create!(email: "donor_approval_charity@example.com", password: "password123", role: :charity)
    @donor_user = User.create!(email: "donor_approval_owner@example.com", password: "password123", role: :donor)
    @admin_user = User.create!(email: "donor_approval_admin@example.com", password: "password123", role: :admin)

    @donor = Donor.create!(user: @donor_user, display_name: "Approval Test Donor")
  end

  test "charity cannot approve a donor" do
    sign_in @charity_user
    patch approve_donor_path(id: @donor.id, locale: :en)
    assert_redirected_to root_path
    assert_not @donor.reload.approved?
  end

  test "charity cannot delete a donor" do
    sign_in @charity_user
    delete donor_path(id: @donor.id, locale: :en)
    assert_redirected_to root_path
    assert Donor.exists?(@donor.id)
  end

  test "donor cannot approve itself" do
    sign_in @donor_user
    patch approve_donor_path(id: @donor.id, locale: :en)
    assert_redirected_to root_path
    assert_not @donor.reload.approved?
  end

  test "admin can approve a donor" do
    sign_in @admin_user
    patch approve_donor_path(id: @donor.id, locale: :en)
    assert_response :redirect
    assert @donor.reload.approved?
  end
end
