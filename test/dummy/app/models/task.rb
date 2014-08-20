class Task < ActiveRecord::Base
  belongs_to :assignment
  belongs_to :project
  has_many :sub_tasks
end
