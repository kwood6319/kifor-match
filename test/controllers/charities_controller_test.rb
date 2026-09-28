require "test_helper"

class CharitiesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @donor_user = User.create!(email: "approval_donor@example.com", password: "password123", role: :donor)
    @charity_user = User.create!(email: "approval_charity@example.com", password: "password123", role: :charity)
    @admin_user = User.create!(email: "approval_admin@example.com", password: "password123", role: :admin)

    @charity = Charity.create!(user: @charity_user, org_name: "Approval Test Charity", region: "Kanto")
  end

  test "donor cannot approve charity" do
    sign_in @donor_user
    patch approve_charity_path(id: @charity.id, locale: :en)
    assert_redirected_to root_path
    assert_not @charity.reload.approved?
  end

  test "donor cannot delete a charity" do
    sign_in @donor_user
    delete charity_path(id: @charity.id, locale: :en)
    assert_redirected_to root_path
    assert Charity.exists?(@charity.id)
  end

  test "charity cannot approve itself" do
    sign_in @charity_user
    patch approve_charity_path(id: @charity.id, locale: :en)
    assert_redirected_to root_path
    assert_not @charity.reload.approved?
  end

  test "admin can approve a charity" do
    sign_in @admin_user
    patch approve_charity_path(id: @charity.id, locale: :en)
    assert_response :redirect
    assert @charity.reload.approved?
  end
end
