require 'test_helper'

class RequestPolicyTest < ActiveSupport::TestCase
  def test_scope
  end

  def test_show
  end

  def test_create
  end

  def test_update
  end

  def test_destroy
  end

  def test_archive
    owning_charity = Charity.new
    owner = User.new(role: :charity).tap { |u| u.charity = owning_charity }
    other_owner = User.new(role: :charity).tap { |u| u.charity = Charity.new }

    fulfilled_request = Request.new(charity: owning_charity, quantity_remaining: 0, status: "active")
    unfulfilled_request = Request.new(charity: owning_charity, quantity_remaining: 3, status: "active")
    archived_request = Request.new(charity: owning_charity, quantity_remaining: 0, status: "archived")

    assert RequestPolicy.new(owner, fulfilled_request).archive?
    assert_not RequestPolicy.new(owner, unfulfilled_request).archive?
    assert_not RequestPolicy.new(owner, archived_request).archive?
    assert_not RequestPolicy.new(other_owner, fulfilled_request).archive?
  end
end
