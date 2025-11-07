class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscribed_communities, through: :subscriptions, source: :community
  has_many :comments, dependent: :destroy
  validates :username, presence: true, uniqueness: true
  validates :display_name, presence: true
end