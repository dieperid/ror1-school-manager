class Student < ApplicationRecord
  belongs_to :person
  belongs_to :departure_reason, optional: true

  validates :person_id, uniqueness: true
  validates :repeating_grade, inclusion: { in: [true, false] }
  validate :student_dates_are_ordered

  private

  def student_dates_are_ordered
    return if admission_date.blank? || departure_date.blank?
    return if departure_date >= admission_date

    errors.add(:departure_date, "must be on or after the admission date")
  end
end
