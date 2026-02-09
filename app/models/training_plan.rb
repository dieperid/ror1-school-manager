class TrainingPlan < ApplicationRecord
  has_many :school_classes, dependent: :restrict_with_exception
  has_many :training_plan_modules, dependent: :destroy
  has_many :school_modules, through: :training_plan_modules, source: :school_module

  validates :name, presence: true
end
