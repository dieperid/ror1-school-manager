class DepartureReason < ApplicationRecord
  has_many :students, dependent: :restrict_with_exception

  validates :title, presence: true, uniqueness: true
end
