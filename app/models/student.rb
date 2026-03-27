class Student < ApplicationRecord
  belongs_to :person
  belongs_to :departure_reason, optional: true
  has_many :class_enrollments, dependent: :restrict_with_exception
  has_many :school_classes, -> { order(:name) }, through: :class_enrollments
  has_many :formation_plans, -> { distinct.reorder("formation_plans.name ASC") }, through: :school_classes
  has_many :grades, dependent: :restrict_with_exception

  validates :person_id, uniqueness: true
  validates :repeating_grade, inclusion: { in: [true, false] }
  validate :student_dates_are_ordered

  delegate :full_name, to: :person

  def school_class_names
    school_classes.map(&:name)
  end

  def scheduled_lectures_between(range)
    Lecture.joins(unit: { learning_modules: :formation_plans })
           .includes(:room, :unit, collaborator: :person)
           .where(formation_plans: { id: school_classes.select(:formation_plan_id) }, date: range)
           .distinct
           .order(:date, :start_time)
  end

  private

  def student_dates_are_ordered
    return if admission_date.blank? || departure_date.blank?
    return if departure_date >= admission_date

    errors.add(:departure_date, "must be on or after the admission date")
  end
end
