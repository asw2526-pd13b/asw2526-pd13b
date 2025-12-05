class Save < ApplicationRecord
  belongs_to :user
  belongs_to :saveable, polymorphic: true

  validates :user_id, uniqueness: { scope: [:saveable_type, :saveable_id] }
end