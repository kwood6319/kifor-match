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
end
