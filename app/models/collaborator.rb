class Collaborator < ApplicationRecord
  belongs_to :person
  has_many :collaborator_assignments, dependent: :destroy
  has_many :collaborator_roles, -> { order(:title) }, through: :collaborator_assignments
  has_many :responsible_school_classes,
           class_name: "SchoolClass",
           foreign_key: :responsible_collaborator_id,
           inverse_of: :responsible_collaborator
  has_many :lectures, dependent: :restrict_with_exception

  validates :person_id, uniqueness: true
  validate :contract_dates_are_ordered

  delegate :full_name, to: :person

  def role_titles
    collaborator_roles.map(&:title)
  end

  def display_name
    return full_name if role_titles.empty?

    "#{full_name} (#{role_titles.join(', ')})"
  end

  def has_role_title?(title)
    collaborator_roles.any? { |collaborator_role| collaborator_role.title.casecmp?(title) }
  end

  def dean?
    has_role_title?("Dean")
  end

  private

  def contract_dates_are_ordered
    return if contract_begin.blank? || contract_end.blank?
    return if contract_end >= contract_begin

    errors.add(:contract_end, "must be on or after the contract start date")
  end
end
