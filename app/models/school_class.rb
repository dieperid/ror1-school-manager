class SchoolClass < ApplicationRecord
  belongs_to :formation_plan
  belongs_to :responsible_collaborator, class_name: "Collaborator"
  has_many :class_enrollments, dependent: :restrict_with_exception
  has_many :students, through: :class_enrollments

  validates :name, presence: true, uniqueness: true

  def responsible_name
    responsible_collaborator.display_name
  end

  def student_count
    students.size
  end
end
