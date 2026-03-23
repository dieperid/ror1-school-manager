require "test_helper"

class ProfileFlowTest < ActionDispatch::IntegrationTest
  test "admin profile shows collaborator roles" do
    sign_in accounts(:admin)

    get profile_path

    assert_response :success
    assert_match "Collaborator", response.body
    assert_match "Administrator", response.body
  end

  test "member can view and update personal information" do
    sign_in accounts(:member)

    travel_to Date.new(2026, 3, 18) do
      get profile_path
      assert_response :success
      assert_match "My profile", response.body
      assert_match "Student", response.body
      assert_match "My schedule", response.body
      assert_match "Open full calendar", response.body
      assert_match "HTML &amp; CSS", response.body
      assert_match "08:15 - 10:00", response.body
      assert_match "System Administrator", response.body
      assert_match "My grades", response.body
      assert_match "5.5", response.body
    end

    patch profile_path, params: {
      person: {
        city: "Sion",
        first_name: "Regular Updated"
      },
      account: {
        email: accounts(:member).email,
        current_password: "",
        password: "",
        password_confirmation: ""
      }
    }

    assert_redirected_to profile_path
    person = people(:member_person).reload
    assert_equal "Regular Updated", person.first_name
    assert_equal "Sion", person.city
  end

  test "member can change email and password with the current password" do
    sign_in accounts(:member)

    patch profile_path, params: {
      person: {
        first_name: people(:member_person).first_name,
        last_name: people(:member_person).last_name
      },
      account: {
        email: "member.updated@example.com",
        current_password: "password123",
        password: "new-password-123",
        password_confirmation: "new-password-123"
      }
    }

    assert_redirected_to profile_path
    account = accounts(:member).reload
    assert_equal "member.updated@example.com", account.email
    assert account.valid_password?("new-password-123")
  end
end
