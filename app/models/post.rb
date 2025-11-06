class Post < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :url, presence: true, format: URI::DEFAULT_PARSER.make_regexp(%w[http https])
  validates :community, presence: true
end