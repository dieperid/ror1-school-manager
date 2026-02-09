class SchoolModule < ApplicationRecord
  has_many :training_plan_modules, dependent: :destroy, inverse_of: :school_module
  has_many :training_plans, through: :training_plan_modules
  has_many :units, dependent: :restrict_with_exception, inverse_of: :school_module

  validates :name, presence: true
end
