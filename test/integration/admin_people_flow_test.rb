require "test_helper"
require "cgi"
require "uri"

class AdminPeopleFlowTest < ActionDispatch::IntegrationTest
  test "guest root renders the devise sign in page" do
    get root_path

    assert_response :success
    assert_match "Log in", response.body
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

  test "admin creates a person and downloads an invitation file" do
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
            email: "jane.doe@example.com"
          }
        }
      end
    end

    person = Person.find_by!(avs_number: "756.0000.0000.03")
    account = person.account

    assert_redirected_to admin_person_account_invitation_path(person, format: :txt)
    follow_redirect!

    assert_response :success
    assert_equal "text/plain", response.media_type
    assert_includes response.headers["Content-Disposition"], ".txt"
    assert_match "Username: jane.doe@example.com", response.body
    assert_match "Set password link:", response.body
    assert_equal "jane.doe@example.com", account.email
    assert_not account.admin?
    assert_not_nil account.invited_at
    assert_not_nil account.reset_password_token

    url = response.body.lines.find { |line| line.start_with?("http") }&.strip
    assert_not_nil url

    token = CGI.parse(URI.parse(url).query).fetch("reset_password_token").first
    assert_equal account.id, Account.with_reset_password_token(token).id
  end

  test "admin can read update and delete a person" do
    sign_in accounts(:admin)
    person = people(:member_person)

    get admin_person_path(person)
    assert_response :success
    assert_match person.full_name, response.body

    patch admin_person_path(person), params: {
      person: {
        city: "Neuchatel",
        first_name: "Updated"
      }
    }

    assert_redirected_to admin_person_path(person)
    assert_equal "Updated", person.reload.first_name
    assert_equal "Neuchatel", person.city

    assert_difference("Person.count", -1) do
      assert_difference("Account.count", -1) do
        delete admin_person_path(person)
      end
    end
  end

  test "admin can create update and delete an account for an existing person" do
    sign_in accounts(:admin)
    person = people(:unlinked_person)

    get new_admin_person_account_path(person)
    assert_response :success

    assert_difference("Account.count", 1) do
      post admin_person_account_path(person), params: {
        account: {
          email: "pending.person@example.com",
          admin: "0",
          enabled: "1"
        }
      }
    end

    account = person.reload.account
    assert_redirected_to admin_person_account_invitation_path(person, format: :txt)
    follow_redirect!
    assert_response :success
    assert_equal "text/plain", response.media_type
    assert_equal "pending.person@example.com", account.email

    patch admin_person_account_path(person), params: {
      account: {
        email: "pending.admin@example.com",
        admin: "1",
        enabled: "1",
        password: "",
        password_confirmation: ""
      }
    }

    assert_redirected_to admin_person_account_path(person)
    account.reload
    assert_equal "pending.admin@example.com", account.email
    assert account.admin?

    assert_difference("Account.count", -1) do
      delete admin_person_account_path(person)
    end
  end
end
