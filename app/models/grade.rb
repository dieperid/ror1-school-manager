class Grade < ApplicationRecord
  belongs_to :student
  belongs_to :unit

  validates :grade_value, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 9.9 }
  validates :test_date, presence: true
end
