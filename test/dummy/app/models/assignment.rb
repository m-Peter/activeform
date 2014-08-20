class Assignment < ActiveRecord::Base
  has_many :tasks
  validates :name, uniqueness: true
end
