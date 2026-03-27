require "test_helper"

class DeanAccessFlowTest < ActionDispatch::IntegrationTest
  test "dean can access management pages and download a student report card" do
    sign_in accounts(:dean)

    get root_path
    assert_response :success
    assert_match "Management dashboard", response.body

    get admin_people_path
    assert_response :success
    assert_match people(:member_person).full_name, response.body

    get admin_units_path
    assert_response :success
    assert_match units(:ruby_unit).name, response.body
    assert_match units(:html_unit).name, response.body

    get admin_person_report_card_path(people(:member_person), format: :txt)
    assert_response :success
    assert_equal "text/plain", response.media_type
    assert_match "Ror1 School Manager report card", response.body
    assert_match people(:member_person).full_name, response.body
    assert_match units(:html_unit).name, response.body
    assert_match "5.50", response.body
  end

  test "dean cannot delete or demote an admin account" do
    sign_in accounts(:dean)
    admin_person = people(:admin_person)

    assert_no_difference("Account.count") do
      delete admin_person_account_path(admin_person)
    end

    assert_redirected_to admin_person_account_path(admin_person)
    follow_redirect!
    assert_match "Dean access cannot delete an admin account.", response.body

    patch admin_person_account_path(admin_person), params: {
      account: {
        email: accounts(:admin).email,
        enabled: "1",
        admin: "0",
        password: "",
        password_confirmation: ""
      }
    }

    assert_redirected_to admin_person_account_path(admin_person)
    follow_redirect!
    assert_match "Dean access cannot disable or remove admin access from an admin account.", response.body
    assert accounts(:admin).reload.admin?
    assert accounts(:admin).enabled?
  end

  test "dean cannot delete a person linked to an admin account" do
    sign_in accounts(:dean)

    assert_no_difference("Person.count") do
      delete admin_person_path(people(:admin_person))
    end

    assert_redirected_to admin_person_path(people(:admin_person))
    follow_redirect!
    assert_match "Dean access cannot delete a person linked to an admin account.", response.body
  end
end
