require "test_helper"

class AdminCurriculumFlowTest < ActionDispatch::IntegrationTest
  test "admin can manage units" do
    sign_in accounts(:admin)

    get admin_units_path
    assert_response :success
    assert_match units(:html_unit).name, response.body

    assert_difference("Unit.count", 1) do
      post admin_units_path, params: {
        unit: {
          name: "Databases"
        }
      }
    end

    unit = Unit.find_by!(name: "Databases")
    assert_redirected_to admin_unit_path(unit)

    patch admin_unit_path(unit), params: {
      unit: {
        name: "Databases and SQL"
      }
    }

    assert_redirected_to admin_unit_path(unit)
    assert_equal "Databases and SQL", unit.reload.name

    assert_difference("Unit.count", -1) do
      delete admin_unit_path(unit)
    end
  end

  test "admin can manage learning modules and assign plans and units" do
    sign_in accounts(:admin)

    get admin_learning_modules_path
    assert_response :success
    assert_match learning_modules(:web_fundamentals_module).name, response.body

    assert_difference("LearningModule.count", 1) do
      assert_difference("FormationPlanModule.count", 1) do
        assert_difference("ModuleUnit.count", 2) do
          post admin_learning_modules_path, params: {
            learning_module: {
              name: "Programming Foundations",
              formation_plan_ids: [formation_plans(:informatics_plan).id],
              unit_ids: [units(:html_unit).id, units(:ruby_unit).id]
            }
          }
        end
      end
    end

    learning_module = LearningModule.find_by!(name: "Programming Foundations")
    assert_redirected_to admin_learning_module_path(learning_module)
    follow_redirect!

    assert_response :success
    assert_match "Programming Foundations", response.body
    assert_match "Informatics", response.body
    assert_match "HTML & CSS", response.body
    assert_match "Ruby Basics", response.body

    patch admin_learning_module_path(learning_module), params: {
      learning_module: {
        name: "Programming Foundations Advanced",
        formation_plan_ids: [formation_plans(:informatics_plan).id, formation_plans(:business_plan).id],
        unit_ids: [units(:ruby_unit).id]
      }
    }

    assert_redirected_to admin_learning_module_path(learning_module)
    learning_module.reload
    assert_equal "Programming Foundations Advanced", learning_module.name
    assert_equal ["Business", "Informatics"], learning_module.formation_plans.order(:name).pluck(:name)
    assert_equal ["Ruby Basics"], learning_module.units.order(:name).pluck(:name)

    get admin_formation_plan_path(formation_plans(:informatics_plan))
    assert_response :success
    assert_match "Programming Foundations Advanced", response.body

    assert_difference("LearningModule.count", -1) do
      delete admin_learning_module_path(learning_module)
    end
  end
end
