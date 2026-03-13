class FormationPlan < ApplicationRecord
  has_many :school_classes, dependent: :restrict_with_exception
  has_many :formation_plan_modules, dependent: :destroy
  has_many :learning_modules, -> { order(:name) }, through: :formation_plan_modules

  validates :name, presence: true, uniqueness: true

  def class_count
    school_classes.size
  end

  def module_count
    learning_modules.size
  end
end
