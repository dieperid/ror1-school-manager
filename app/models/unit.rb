class Unit < ApplicationRecord
  has_many :module_units, dependent: :destroy
  has_many :learning_modules, -> { order(:name) }, through: :module_units
  has_many :lectures, dependent: :restrict_with_exception
  has_many :grades, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true

  def module_count
    learning_modules.size
  end

  def lecture_count
    lectures.size
  end

  def grade_count
    grades.size
  end
end
