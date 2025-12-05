class Post < ApplicationRecord
  belongs_to :user
  belongs_to :community
  has_one_attached :image
  has_many :comments, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy
  has_many :saves, class_name: 'Save', as: :saveable, dependent: :destroy

  validates :title, presence: true
  validates :url, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])

  def score
    s = votes.sum(:value).to_i
    s < 0 ? 0 : s
  end
end
