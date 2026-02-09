class Person < ApplicationRecord
  has_one :account, dependent: :restrict_with_exception
  has_one :collaborator, dependent: :restrict_with_exception
  has_one :student, dependent: :restrict_with_exception

  validates :avs_number, :first_name, :last_name, presence: true
  validates :avs_number, uniqueness: true
  validates :postal_code, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :street_number, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true
  validate :birth_date_cannot_be_in_the_future

  private

  def birth_date_cannot_be_in_the_future
    return if birth_date.blank? || birth_date <= Date.current

    errors.add(:birth_date, "can't be in the future")
  end
end
