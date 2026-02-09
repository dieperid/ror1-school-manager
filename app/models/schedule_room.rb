class ScheduleRoom < ApplicationRecord
  self.primary_key = nil

  belongs_to :schedule
  belongs_to :room

  validates :room_id, uniqueness: { scope: :schedule_id }
end
