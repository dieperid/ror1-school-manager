require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "disabled accounts are rejected by devise" do
    account = accounts(:member)
    account.enabled = false

    assert_not account.active_for_authentication?
    assert_equal :disabled, account.inactive_message
  end

  test "generate_password_setup_token stamps the account and stores a recoverable token" do
    account = accounts(:member)

    token = account.generate_password_setup_token!

    account.reload
    assert_not_nil token
    assert_not_nil account.invited_at
    assert_not_nil account.reset_password_token
    assert_equal account.id, Account.with_reset_password_token(token).id
  end
end
