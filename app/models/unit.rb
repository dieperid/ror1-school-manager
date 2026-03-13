class Unit < ApplicationRecord
  has_many :module_units, dependent: :destroy
  has_many :learning_modules, -> { order(:name) }, through: :module_units

  validates :name, presence: true, uniqueness: true

  def module_count
    learning_modules.size
  end
end
