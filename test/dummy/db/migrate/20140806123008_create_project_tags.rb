class CreateProjectTags < ActiveRecord::Migration
  def change
    create_table :project_tags do |t|
      t.references :project, index: true
      t.references :tag, index: true

      t.timestamps
    end
  end
end
