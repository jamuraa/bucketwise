require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test "create should also create default bucket" do
    assert_difference "Bucket.count" do
      a = new_account
      assert_equal %w(default), a.buckets.map(&:role)
      assert_equal a.author, a.buckets.first.author
    end
  end

  test "create without starting balance should initialize with zero items" do
    assert_no_difference "Event.count" do
      a = new_account
      assert a.line_items.count.zero?
      assert a.account_items.count.zero?
      assert a.balance.zero?
    end
  end

  test "create with starting balance should initialize balance" do
    assert_difference "subscriptions(:john).events.count" do
      a = new_account :starting_balance => {
        :occurred_on => 1.week.ago.utc, :amount => "12345" }
      assert_equal [a.buckets.default], a.line_items.map(&:bucket)
      assert_equal 12345, a.balance
    end
  end

  private

    def new_account(options={})
      options = {:name => "Visa",
                 :role => "credit-card",
                 :author => users(:john)}.merge(options)

      subscriptions(:john).accounts.create(options)
    end
end