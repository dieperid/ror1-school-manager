class TrainingPlanModule < ApplicationRecord
  self.primary_key = nil

  belongs_to :training_plan
  belongs_to :school_module, inverse_of: :training_plan_modules

  validates :school_module_id, uniqueness: { scope: :training_plan_id }
end
