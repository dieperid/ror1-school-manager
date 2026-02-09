class CollaboratorRole < ApplicationRecord
  has_many :collaborator_role_assignments, dependent: :destroy
  has_many :collaborators, through: :collaborator_role_assignments

  validates :name, presence: true
end
