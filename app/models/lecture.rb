class Lecture < ApplicationRecord
  belongs_to :room
  belongs_to :collaborator
  belongs_to :unit

  validates :date, :start_time, :end_time, presence: true
  validate :end_time_after_start_time

  def title
    "#{date} #{start_time.strftime('%H:%M')} #{unit.name}"
  end

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    return if end_time > start_time

    errors.add(:end_time, "must be after the start time")
  end
end
