class Schedule < ApplicationRecord
  belongs_to :school_class, optional: true, inverse_of: :schedules
  belongs_to :collaborator

  has_many :schedule_units, dependent: :destroy
  has_many :units, through: :schedule_units
  has_many :schedule_rooms, dependent: :destroy
  has_many :rooms, through: :schedule_rooms

  validates :day, :start_time, :end_time, presence: true
  validate :end_time_after_start_time

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    return if end_time > start_time

    errors.add(:end_time, "must be after start time")
  end
end
