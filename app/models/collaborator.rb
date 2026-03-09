class Collaborator < ApplicationRecord
  belongs_to :person

  validates :person_id, uniqueness: true
  validate :contract_dates_are_ordered

  private

  def contract_dates_are_ordered
    return if contract_begin.blank? || contract_end.blank?
    return if contract_end >= contract_begin

    errors.add(:contract_end, "must be on or after the contract start date")
  end
end
