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

  def generate_password_setup_token!
    token = send(:set_reset_password_token)
    update!(invited_at: Time.current)
    token
  end

  def person_name
    person.full_name
  end

  def dean?
    person&.dean? || false
  end

  def admin_or_dean?
    admin? || dean?
  end

  def access_label
    return "Admin" if admin?
    return "Dean" if dean?

    "Standard"
  end
end
