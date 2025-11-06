class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  validates :username, presence: true, uniqueness: true
  validates :display_name, presence: true
end