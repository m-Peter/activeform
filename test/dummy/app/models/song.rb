class Song < ActiveRecord::Base
  has_one :artist, dependent: :destroy

  validates :title, uniqueness: true
end
