class Unit < ApplicationRecord
  belongs_to :school_module, inverse_of: :units

  has_many :grades, dependent: :restrict_with_exception
  has_many :schedule_units, dependent: :destroy
  has_many :schedules, through: :schedule_units

  validates :name, presence: true
end
