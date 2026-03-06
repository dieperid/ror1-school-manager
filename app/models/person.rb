class Person < ApplicationRecord
  has_one :account, dependent: :destroy

  validates :avs_number, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  def full_name
    [first_name, last_name].join(" ")
  end
end
