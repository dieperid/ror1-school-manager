class FormationPlanModule < ApplicationRecord
  belongs_to :formation_plan
  belongs_to :learning_module

  validates :learning_module_id, uniqueness: { scope: :formation_plan_id }
end
