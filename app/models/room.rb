class Room < ApplicationRecord
  has_many :lectures, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true

  def lecture_count
    lectures.size
  end
end
