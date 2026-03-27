require "test_helper"

class AdminCollaboratorRolesFlowTest < ActionDispatch::IntegrationTest
  test "non admin accounts cannot access collaborator roles" do
    sign_in accounts(:member)

    get admin_collaborator_roles_path

    assert_redirected_to root_path
    follow_redirect!
    assert_match "You are not allowed to access the admin area.", response.body
  end

  test "admin can create a collaborator role from the dedicated page" do
    sign_in accounts(:admin)

    get new_admin_collaborator_role_path
    assert_response :success
    assert_match "Create a reusable collaborator role", response.body

    assert_difference("CollaboratorRole.count", 1) do
      post admin_collaborator_roles_path, params: {
        collaborator_role: {
          title: "Coordinator"
        }
      }
    end

    assert_redirected_to admin_collaborator_roles_path
    follow_redirect!
    assert_response :success
    assert_match "Collaborator role created.", response.body
    assert_match "Coordinator", response.body
  end
end
