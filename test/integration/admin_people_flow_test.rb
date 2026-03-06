require "test_helper"

class AdminPeopleFlowTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "public sign up route is unavailable" do
    get "/accounts/sign_up"

    assert_response :not_found
  end

  test "non admin accounts cannot access admin people" do
    sign_in accounts(:member)

    get admin_people_path

    assert_redirected_to root_path
    follow_redirect!
    assert_match "You are not allowed to access the admin area.", response.body
  end

  test "admin creates a person and sends an invitation" do
    sign_in accounts(:admin)

    assert_difference("Person.count", 1) do
      assert_difference("Account.count", 1) do
        post admin_people_path, params: {
          person: {
            avs_number: "756.0000.0000.03",
            first_name: "Jane",
            last_name: "Doe",
            birth_date: "2001-04-15",
            city: "Yverdon-les-Bains",
            postal_code: "1400",
            street: "Rue du Lac",
            street_number: "11",
            phone_number: "0770000000"
          },
          account: {
            email: "jane.doe@example.com",
            admin: "0"
          }
        }
      end
    end

    assert_redirected_to admin_people_path
    follow_redirect!
    assert_match "An invitation was sent to jane.doe@example.com.", response.body

    person = Person.find_by!(avs_number: "756.0000.0000.03")
    account = person.account

    assert_equal "jane.doe@example.com", account.email
    assert_not account.admin?
    assert_not_nil account.invited_at
    assert_not_nil account.reset_password_token
    assert_equal 1, ActionMailer::Base.deliveries.size
  end
end
