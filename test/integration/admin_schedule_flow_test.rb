require "test_helper"

class AdminScheduleFlowTest < ActionDispatch::IntegrationTest
  test "admin can manage rooms" do
    sign_in accounts(:admin)

    get admin_rooms_path
    assert_response :success
    assert_match rooms(:lab_a).name, response.body

    assert_difference("Room.count", 1) do
      post admin_rooms_path, params: {
        room: {
          name: "Auditorium"
        }
      }
    end

    room = Room.find_by!(name: "Auditorium")
    assert_redirected_to admin_room_path(room)

    patch admin_room_path(room), params: {
      room: {
        name: "Main Auditorium"
      }
    }

    assert_redirected_to admin_room_path(room)
    assert_equal "Main Auditorium", room.reload.name

    assert_difference("Room.count", -1) do
      delete admin_room_path(room)
    end
  end

  test "admin cannot delete a room with linked lectures" do
    sign_in accounts(:admin)
    room = rooms(:lab_a)

    assert_no_difference("Room.count") do
      delete admin_room_path(room)
    end

    assert_redirected_to admin_room_path(room)
    follow_redirect!
    assert_match "Delete the lectures linked to this room first.", response.body
  end

  test "admin can manage lectures" do
    sign_in accounts(:admin)

    get admin_lectures_path
    assert_response :success
    assert_match units(:html_unit).name, response.body

    get new_admin_lecture_path
    assert_response :success

    assert_difference("Lecture.count", 1) do
      post admin_lectures_path, params: {
        lecture: {
          date: "2026-04-02",
          start_time: "13:15",
          end_time: "15:00",
          room_id: rooms(:room_b12).id,
          unit_id: units(:ruby_unit).id,
          collaborator_id: collaborators(:admin_collaborator).id
        }
      }
    end

    lecture = Lecture.find_by!(date: Date.new(2026, 4, 2), room: rooms(:room_b12))
    assert_redirected_to admin_lecture_path(lecture)
    follow_redirect!

    assert_response :success
    assert_match "Ruby Basics", response.body
    assert_match "Room B12", response.body
    assert_match "System Administrator", response.body

    patch admin_lecture_path(lecture), params: {
      lecture: {
        date: "2026-04-03",
        start_time: "14:00",
        end_time: "16:15",
        room_id: rooms(:lab_a).id,
        unit_id: units(:accounting_unit).id,
        collaborator_id: collaborators(:admin_collaborator).id
      }
    }

    assert_redirected_to admin_lecture_path(lecture)
    lecture.reload
    assert_equal Date.new(2026, 4, 3), lecture.date
    assert_equal rooms(:lab_a), lecture.room
    assert_equal units(:accounting_unit), lecture.unit

    get admin_unit_path(units(:accounting_unit))
    assert_response :success
    assert_match "14:00 - 16:15", response.body
    assert_match "Lab A", response.body

    assert_difference("Lecture.count", -1) do
      delete admin_lecture_path(lecture)
    end
  end
end
