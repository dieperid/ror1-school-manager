class ClassEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :school_class

  validates :student_id, uniqueness: { scope: :school_class_id }
end
