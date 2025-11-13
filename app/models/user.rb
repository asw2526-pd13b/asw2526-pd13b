class User < ApplicationRecord
  devise :omniauthable, :trackable, omniauth_providers: [:github]

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscribed_communities, through: :subscriptions, source: :community

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  def self.from_omniauth(auth)
    email = auth.info.email
    email = "#{auth.uid}@github.local" if email.blank?
    username = auth.info.nickname
    username = auth.info.name if username.blank?
    username = "user_#{auth.uid}" if username.blank?

    user = where(provider: auth.provider, uid: auth.uid).first_or_initialize
    user.email = email
    user.username = username
    if user.display_name.blank? && auth.info.name.present?
      user.display_name = auth.info.name
    end
    if auth.info.image.present?
      user.avatar_url = auth.info.image
    end
    user.save!
    user
  rescue ActiveRecord::RecordInvalid
    nil
  end

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
