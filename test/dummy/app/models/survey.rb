class Survey < ActiveRecord::Base
  has_many :questions, dependent: :destroy

  validates :name, uniqueness: true
end
