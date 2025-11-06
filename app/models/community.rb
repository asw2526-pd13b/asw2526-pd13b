class Community < ApplicationRecord
  has_many :posts, dependent: :destroy

  # ActiveStorage
  has_one_attached :banner
  has_one_attached :avatar

  # Validaciones
  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9-]+\z/, message: "usa solo minúsculas, números y guiones" }
  # name es opcional

  # Usar slug en las URLs (/communities/:slug)
  def to_param
    slug
  end
end