class Collaborator < ApplicationRecord
  belongs_to :person

  has_one :account, through: :person
  has_many :collaborator_role_assignments, dependent: :destroy
  has_many :collaborator_roles, through: :collaborator_role_assignments
  has_many :responsible_school_classes,
           class_name: "SchoolClass",
           foreign_key: :responsible_collaborator_id,
           dependent: :restrict_with_exception,
           inverse_of: :responsible_collaborator
  has_many :schedules, dependent: :restrict_with_exception

  validates :is_teacher, inclusion: { in: [ true, false ] }, allow_nil: true
  validate :contract_end_after_contract_start

  private

  def contract_end_after_contract_start
    return if contract_start.blank? || contract_end.blank?
    return if contract_end >= contract_start

    errors.add(:contract_end, "must be after or equal to contract start")
  end
end
