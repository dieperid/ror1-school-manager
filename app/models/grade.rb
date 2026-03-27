class Grade < ApplicationRecord
  belongs_to :student
  belongs_to :unit

  validates :value, presence: true, numericality: true
  validates :awarded_on, presence: true
  validates :awarded_on, uniqueness: { scope: %i[student_id unit_id] }

  def student_name
    student.full_name
  end
end
