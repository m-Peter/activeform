class CreateDeliverables < ActiveRecord::Migration
  def change
    create_table :deliverables do |t|
      t.text :description
      t.references :task, index: true

      t.timestamps
    end
  end
end
