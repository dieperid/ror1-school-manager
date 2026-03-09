class Collaborator < ApplicationRecord
  belongs_to :person
  has_many :collaborator_assignments, dependent: :destroy
  has_many :collaborator_roles, -> { order(:title) }, through: :collaborator_assignments

  validates :person_id, uniqueness: true
  validate :contract_dates_are_ordered

  def role_titles
    collaborator_roles.map(&:title)
  end

  private

  def contract_dates_are_ordered
    return if contract_begin.blank? || contract_end.blank?
    return if contract_end >= contract_begin

    errors.add(:contract_end, "must be on or after the contract start date")
  end
end
