class LearningModule < ApplicationRecord
  has_many :module_units, dependent: :destroy
  has_many :units, -> { order(:name) }, through: :module_units
  has_many :formation_plan_modules, dependent: :destroy
  has_many :formation_plans, -> { order(:name) }, through: :formation_plan_modules

  validates :name, presence: true, uniqueness: true

  def unit_count
    units.size
  end

  def formation_plan_count
    formation_plans.size
  end
end
