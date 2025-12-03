class User < ApplicationRecord
  devise :omniauthable, :trackable, omniauth_providers: [:github]

  # Associacions
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :subscribed_communities, through: :subscriptions, source: :community
  has_many :votes, dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :api_key, uniqueness: true, allow_nil: true

   # Generar API key abans de crear l'usuari
  before_create :generate_api_key

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

  # Generar nova API key
  def regenerate_api_key!
    update(api_key: generate_unique_api_key)
  end

  private

  def generate_api_key
    self.api_key = generate_unique_api_key
  end

  def generate_unique_api_key
    loop do
      token = SecureRandom.hex(32)
      break token unless User.exists?(api_key: token)
    end
  end
end