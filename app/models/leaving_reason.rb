class LeavingReason < ApplicationRecord
  has_many :students, dependent: :restrict_with_exception

  validates :title, presence: true
end
