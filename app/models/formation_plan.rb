class FormationPlan < ApplicationRecord
  has_many :school_classes, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true

  def class_count
    school_classes.size
  end
end
