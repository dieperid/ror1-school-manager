require "test_helper"

class ScheduleFlowTest < ActionDispatch::IntegrationTest
  test "collaborator can view their schedule calendar" do
    sign_in accounts(:teacher)

    get schedule_path(start_date: "2026-03-01")

    assert_response :success
    assert_match "My schedule", response.body
    assert_match "March 2026", response.body
    assert_match "Ruby Basics", response.body
    assert_match "10:15 - 12:00", response.body
    assert_match "Lab A", response.body
  end

  test "student can view their schedule calendar" do
    sign_in accounts(:member)

    get schedule_path(start_date: "2026-03-01")

    assert_response :success
    assert_match "My schedule", response.body
    assert_match "March 2026", response.body
    assert_match "HTML &amp; CSS", response.body
    assert_match "08:15 - 10:00", response.body
    assert_match "Lab A", response.body
    assert_match "System Administrator", response.body
  end
end
