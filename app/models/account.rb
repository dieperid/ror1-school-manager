class Account < ApplicationRecord
  belongs_to :person

  validates :email, :password_hash, presence: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :account_status, inclusion: { in: [ true, false ] }
  validates :person_id, uniqueness: true
end
