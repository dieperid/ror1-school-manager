class ScheduleUnit < ApplicationRecord
  self.primary_key = nil

  belongs_to :schedule
  belongs_to :unit

  validates :unit_id, uniqueness: { scope: :schedule_id }
end
