require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "disabled accounts are rejected by devise" do
    account = accounts(:member)
    account.enabled = false

    assert_not account.active_for_authentication?
    assert_equal :disabled, account.inactive_message
  end

  test "deliver_invitation stamps the account and sends email" do
    account = accounts(:member)

    assert_difference("ActionMailer::Base.deliveries.size", 1) do
      account.deliver_invitation!
    end

    account.reload
    assert_not_nil account.invited_at
    assert_not_nil account.reset_password_token
  end
end
