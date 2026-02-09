class Room < ApplicationRecord
  has_many :schedule_rooms, dependent: :destroy
  has_many :schedules, through: :schedule_rooms

  validates :name, presence: true
end
