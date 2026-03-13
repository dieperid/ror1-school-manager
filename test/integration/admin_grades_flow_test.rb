require "test_helper"

class AdminGradesFlowTest < ActionDispatch::IntegrationTest
  test "admin can manage grades" do
    sign_in accounts(:admin)

    get admin_grades_path
    assert_response :success
    assert_match "5.5", response.body

    assert_difference("Grade.count", 1) do
      post admin_grades_path, params: {
        grade: {
          student_id: students(:member_student).id,
          unit_id: units(:ruby_unit).id,
          awarded_on: "2026-03-21",
          value: "4.5"
        }
      }
    end

    grade = Grade.find_by!(student: students(:member_student), unit: units(:ruby_unit), awarded_on: Date.new(2026, 3, 21))
    assert_redirected_to admin_grade_path(grade)
    follow_redirect!

    assert_response :success
    assert_match "Ruby Basics", response.body
    assert_match "4.5", response.body

    patch admin_grade_path(grade), params: {
      grade: {
        student_id: students(:member_student).id,
        unit_id: units(:accounting_unit).id,
        awarded_on: "2026-03-22",
        value: "5.0"
      }
    }

    assert_redirected_to admin_grade_path(grade)
    grade.reload
    assert_equal units(:accounting_unit), grade.unit
    assert_equal Date.new(2026, 3, 22), grade.awarded_on
    assert_equal BigDecimal("5.0"), grade.value

    get admin_person_path(people(:member_person))
    assert_response :success
    assert_match "Accounting Basics", response.body

    get admin_unit_path(units(:accounting_unit))
    assert_response :success
    assert_match "5.0", response.body

    assert_difference("Grade.count", -1) do
      delete admin_grade_path(grade)
    end
  end

  test "admin cannot create duplicate grade for same student unit and date" do
    sign_in accounts(:admin)

    assert_no_difference("Grade.count") do
      post admin_grades_path, params: {
        grade: {
          student_id: students(:member_student).id,
          unit_id: units(:html_unit).id,
          awarded_on: "2026-02-10",
          value: "4.0"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "Awarded on has already been taken", response.body
  end
end
