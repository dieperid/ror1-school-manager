class Account < ApplicationRecord
  TEMP_PASSWORD_LENGTH = 20

  belongs_to :person

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  validates :email, presence: true

  scope :admins, -> { where(admin: true) }

  def self.generate_temporary_password
    Devise.friendly_token.first(TEMP_PASSWORD_LENGTH)
  end

  def active_for_authentication?
    super && enabled?
  end

  def inactive_message
    enabled? ? super : :disabled
  end

  def deliver_invitation!
    update!(invited_at: Time.current)
    send_reset_password_instructions
  end
end
