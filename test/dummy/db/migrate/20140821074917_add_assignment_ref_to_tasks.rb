class AddAssignmentRefToTasks < ActiveRecord::Migration
  def change
    add_reference :tasks, :assignment, index: true
  end
end
