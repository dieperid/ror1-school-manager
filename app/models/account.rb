class Account < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  belongs_to :person

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, :password_hash, presence: true
  validates :email_address, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :account_status, inclusion: { in: [ true, false ] }
  validates :person_id, uniqueness: true
end
