class SchoolClass < ApplicationRecord
  belongs_to :domain
  belongs_to :training_plan
  belongs_to :responsible_collaborator, class_name: "Collaborator", inverse_of: :responsible_school_classes

  has_many :students, dependent: :restrict_with_exception, inverse_of: :school_class
  has_many :schedules, dependent: :nullify, inverse_of: :school_class

  validates :name, presence: true, uniqueness: true
end
