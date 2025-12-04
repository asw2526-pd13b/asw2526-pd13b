class User < ApplicationRecord
  devise :omniauthable, :trackable, omniauth_providers: [:github]

  has_secure_token :api_key

  # Associacions
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscribed_communities, through: :subscriptions, source: :community
  has_many :votes, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.username = auth.info.nickname
      user.display_name = auth.info.name
      user.avatar_url = auth.info.image
    end
  end

  def password_required?
    false
  end

  # Mètodes auxiliars per al perfil
  def posts_count
    posts.count
  end

  def comments_count
    comments.count
  end

  def name
    display_name.presence || username
  end
end
