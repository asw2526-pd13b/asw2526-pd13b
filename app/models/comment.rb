class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  # Respuestas anidadas (opcional)
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :children, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true
end