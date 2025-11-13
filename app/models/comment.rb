class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  # Soporte para hilos (respuestas). parent_id es opcional.
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy

  def score
    votes.sum(:value)
  end

  validates :body, presence: true

  scope :newest_first, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }
end