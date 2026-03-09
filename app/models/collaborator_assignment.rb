class CollaboratorAssignment < ApplicationRecord
  belongs_to :collaborator
  belongs_to :collaborator_role

  validates :collaborator_role_id, uniqueness: { scope: :collaborator_id }
end
