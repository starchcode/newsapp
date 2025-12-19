class Keyword < ApplicationRecord
  belongs_to :user

  validates :keyword, presence: true, uniqueness: { scope: :user_id, message: "already exists for this user" }
  validates :keyword, length: { minimum: 1, maximum: 100 }
end
