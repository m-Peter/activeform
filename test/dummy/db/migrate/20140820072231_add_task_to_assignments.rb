class AddTaskToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :task_id, :integer
  end
end
