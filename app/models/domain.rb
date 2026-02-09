class Domain < ApplicationRecord
  has_many :school_classes, dependent: :restrict_with_exception

  validates :name, presence: true
end
