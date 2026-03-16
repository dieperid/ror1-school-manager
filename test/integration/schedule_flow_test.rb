require "test_helper"

class ScheduleFlowTest < ActionDispatch::IntegrationTest
  test "collaborator can view their schedule calendar" do
    sign_in accounts(:teacher)

    get schedule_path(month: "2026-03")

    assert_response :success
    assert_match "My schedule", response.body
    assert_match "March 2026", response.body
    assert_match "Ruby Basics", response.body
    assert_match "10:15 - 12:00", response.body
    assert_match "Lab A", response.body
  end

  test "student cannot access collaborator schedule" do
    sign_in accounts(:member)

    get schedule_path

    assert_redirected_to profile_path
    follow_redirect!
    assert_match "You do not have a collaborator schedule.", response.body
  end
end
