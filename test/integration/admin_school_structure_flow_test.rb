require "test_helper"

class AdminSchoolStructureFlowTest < ActionDispatch::IntegrationTest
  test "admin can manage formation plans" do
    sign_in accounts(:admin)

    get admin_formation_plans_path
    assert_response :success
    assert_match formation_plans(:informatics_plan).name, response.body

    assert_difference("FormationPlan.count", 1) do
      post admin_formation_plans_path, params: {
        formation_plan: {
          name: "Cybersecurity"
        }
      }
    end

    formation_plan = FormationPlan.find_by!(name: "Cybersecurity")
    assert_redirected_to admin_formation_plan_path(formation_plan)

    get admin_formation_plan_path(formation_plan)
    assert_response :success
    assert_match "Cybersecurity", response.body

    patch admin_formation_plan_path(formation_plan), params: {
      formation_plan: {
        name: "Business Applications"
      }
    }

    assert_redirected_to admin_formation_plan_path(formation_plan)
    assert_equal "Business Applications", formation_plan.reload.name

    assert_difference("FormationPlan.count", -1) do
      delete admin_formation_plan_path(formation_plan)
    end
  end

  test "admin cannot delete a formation plan with linked classes" do
    sign_in accounts(:admin)
    formation_plan = formation_plans(:informatics_plan)

    assert_no_difference("FormationPlan.count") do
      delete admin_formation_plan_path(formation_plan)
    end

    assert_redirected_to admin_formation_plan_path(formation_plan)
    follow_redirect!
    assert_match "Delete the school classes linked to this formation plan first.", response.body
  end

  test "admin can manage school classes" do
    sign_in accounts(:admin)

    get admin_school_classes_path
    assert_response :success
    assert_match school_classes(:webdev_class).name, response.body
    assert_match "1 student", response.body

    get new_admin_school_class_path
    assert_response :success

    assert_difference("SchoolClass.count", 1) do
      assert_difference("ClassEnrollment.count", 1) do
        post admin_school_classes_path, params: {
          school_class: {
            name: "INF-2026-A",
            formation_plan_id: formation_plans(:informatics_plan).id,
            responsible_collaborator_id: collaborators(:admin_collaborator).id,
            student_ids: [students(:member_student).id]
          }
        }
      end
    end

    school_class = SchoolClass.find_by!(name: "INF-2026-A")
    assert_redirected_to admin_school_class_path(school_class)
    follow_redirect!

    assert_response :success
    assert_match "INF-2026-A", response.body
    assert_match "Informatics", response.body
    assert_match "System Administrator", response.body
    assert_match "Regular Member", response.body

    assert_difference("ClassEnrollment.count", -1) do
      patch admin_school_class_path(school_class), params: {
        school_class: {
          name: "BIZ-2026-B",
          formation_plan_id: formation_plans(:business_plan).id,
          responsible_collaborator_id: collaborators(:admin_collaborator).id,
          student_ids: []
        }
      }
    end

    assert_redirected_to admin_school_class_path(school_class)
    school_class.reload
    assert_equal "BIZ-2026-B", school_class.name
    assert_equal formation_plans(:business_plan), school_class.formation_plan
    assert_empty school_class.students

    assert_difference("SchoolClass.count", -1) do
      delete admin_school_class_path(school_class)
    end
  end
end
