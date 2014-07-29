class Artist < ActiveRecord::Base
  has_one :producer, dependent: :destroy
  belongs_to :song

  validates :name, uniqueness: true
end
