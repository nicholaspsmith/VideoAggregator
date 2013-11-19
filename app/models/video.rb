class Video < ActiveRecord::Base
  validates :youtube_id, presence: true
end
