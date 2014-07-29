class Project < ActiveRecord::Base
  has_many :tasks, dependent: :destroy

  validates :name, uniqueness: true
end
