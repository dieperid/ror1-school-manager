class SchoolClass < ApplicationRecord
  belongs_to :formation_plan
  belongs_to :responsible_collaborator, class_name: "Collaborator"

  validates :name, presence: true, uniqueness: true

  def responsible_name
    responsible_collaborator.display_name
  end
end
