class ModuleUnit < ApplicationRecord
  belongs_to :learning_module
  belongs_to :unit

  validates :unit_id, uniqueness: { scope: :learning_module_id }
end
