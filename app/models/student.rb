class Student < ApplicationRecord
  belongs_to :person
  belongs_to :leaving_reason, optional: true
  belongs_to :school_class, inverse_of: :students

  has_one :account, through: :person
  has_many :grades, dependent: :destroy

  validates :repeat_year, inclusion: { in: [ true, false ] }, allow_nil: true
  validates :person_id, uniqueness: true
  validate :leaving_date_after_admission_date

  private

  def leaving_date_after_admission_date
    return if admission_date.blank? || leaving_date.blank?
    return if leaving_date >= admission_date

    errors.add(:leaving_date, "must be after or equal to admission date")
  end
end
