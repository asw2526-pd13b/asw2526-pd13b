class Post < ApplicationRecord
  belongs_to :user
  belongs_to :community
  has_one_attached :image
  has_many :comments, dependent: :destroy
  validates :title, presence: true
  validates :url, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  has_many :votes, as: :votable, dependent: :destroy
  def score
    votes.sum(:value)
  end
end