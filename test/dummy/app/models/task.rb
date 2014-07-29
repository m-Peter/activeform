class Task < ActiveRecord::Base
  belongs_to :project
  has_one :deliverable, dependent: :destroy
end
