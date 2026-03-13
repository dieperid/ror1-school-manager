require "test_helper"

class AdminGradesFlowTest < ActionDispatch::IntegrationTest
  test "admin can manage grades from the unit page" do
    sign_in accounts(:admin)
    unit = units(:ruby_unit)

    get admin_unit_path(unit)
    assert_response :success
    assert_match "New grade", response.body

    assert_difference("Grade.count", 1) do
      post admin_unit_grades_path(unit), params: {
        grade: {
          student_id: students(:member_student).id,
          awarded_on: "2026-03-21",
          value: "4.5"
        }
      }
    end

    grade = Grade.find_by!(student: students(:member_student), unit: unit, awarded_on: Date.new(2026, 3, 21))
    assert_redirected_to admin_unit_path(unit)
    follow_redirect!

    assert_response :success
    assert_match "Ruby Basics", response.body
    assert_match "4.5", response.body

    patch admin_unit_grade_path(unit, grade), params: {
      grade: {
        student_id: students(:member_student).id,
        awarded_on: "2026-03-22",
        value: "5.0"
      }
    }

    assert_redirected_to admin_unit_path(unit)
    grade.reload
    assert_equal Date.new(2026, 3, 22), grade.awarded_on
    assert_equal BigDecimal("5.0"), grade.value

    get admin_person_path(people(:member_person))
    assert_response :success
    assert_match "Ruby Basics", response.body

    get admin_unit_path(unit)
    assert_response :success
    assert_match "5.0", response.body

    assert_difference("Grade.count", -1) do
      delete admin_unit_grade_path(unit, grade)
    end
  end

  test "admin cannot create duplicate grade for same student unit and date" do
    sign_in accounts(:admin)
    unit = units(:html_unit)

    assert_no_difference("Grade.count") do
      post admin_unit_grades_path(unit), params: {
        grade: {
          student_id: students(:member_student).id,
          awarded_on: "2026-02-10",
          value: "4.0"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "Awarded on has already been taken", response.body
  end

  test "teaching collaborator can manage grades for their unit only" do
    sign_in accounts(:teacher)
    unit = units(:ruby_unit)

    get admin_units_path
    assert_response :success
    assert_match "Ruby Basics", response.body
    assert_no_match "HTML & CSS", response.body

    get admin_unit_path(unit)
    assert_response :success
    assert_match "New grade", response.body
    assert_no_match "Edit unit", response.body

    assert_difference("Grade.count", 1) do
      post admin_unit_grades_path(unit), params: {
        grade: {
          student_id: students(:member_student).id,
          awarded_on: "2026-03-25",
          value: "4.8"
        }
      }
    end

    grade = Grade.find_by!(student: students(:member_student), unit: unit, awarded_on: Date.new(2026, 3, 25))
    assert_redirected_to admin_unit_path(unit)

    get admin_unit_grade_path(unit, grade)
    assert_response :success
    assert_no_match admin_person_path(people(:member_person)), response.body

    patch admin_unit_grade_path(unit, grade), params: {
      grade: {
        student_id: students(:member_student).id,
        awarded_on: "2026-03-26",
        value: "5.2"
      }
    }

    assert_redirected_to admin_unit_path(unit)
    assert_equal BigDecimal("5.2"), grade.reload.value

    assert_difference("Grade.count", -1) do
      delete admin_unit_grade_path(unit, grade)
    end
  end

  test "collaborator cannot access grades for a unit they do not teach" do
    sign_in accounts(:outsider)

    get admin_unit_path(units(:ruby_unit))

    assert_redirected_to root_path

    post admin_unit_grades_path(units(:ruby_unit)), params: {
      grade: {
        student_id: students(:member_student).id,
        awarded_on: "2026-03-27",
        value: "4.0"
      }
    }

    assert_redirected_to root_path
  end
end
