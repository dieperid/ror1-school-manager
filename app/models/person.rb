class Person < ApplicationRecord
  has_one :account, dependent: :destroy
  has_one :collaborator, dependent: :destroy
  has_one :student, dependent: :destroy

  validates :avs_number, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  def full_name
    [ first_name, last_name ].join(" ")
  end

  def dean?
    collaborator&.dean? || false
  end

  def role_type
    return "collaborator" if collaborator.present?
    return "student" if student.present?

    "none"
  end

  def role_label
    case role_type
    when "collaborator"
      "Collaborator"
    when "student"
      "Student"
    else
      "No role"
    end
  end
end
