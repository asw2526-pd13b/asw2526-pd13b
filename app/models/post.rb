class Post < ApplicationRecord
  belongs_to :user
  belongs_to :community
  has_one_attached :image

  validates :title, presence: true
  validates :url, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
end