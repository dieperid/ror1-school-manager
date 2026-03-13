class Student < ApplicationRecord
  belongs_to :person
  belongs_to :departure_reason, optional: true
  has_many :grades, dependent: :restrict_with_exception

  validates :person_id, uniqueness: true
  validates :repeating_grade, inclusion: { in: [true, false] }
  validate :student_dates_are_ordered

  delegate :full_name, to: :person

  private

  def student_dates_are_ordered
    return if admission_date.blank? || departure_date.blank?
    return if departure_date >= admission_date

    errors.add(:departure_date, "must be on or after the admission date")
  end
end
