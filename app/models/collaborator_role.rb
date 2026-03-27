class CollaboratorRole < ApplicationRecord
  has_many :collaborator_assignments, dependent: :restrict_with_exception
  has_many :collaborators, through: :collaborator_assignments

  validates :title, presence: true, uniqueness: true

  before_validation :normalize_title

  private

  def normalize_title
    self.title = title.to_s.strip
  end
end
