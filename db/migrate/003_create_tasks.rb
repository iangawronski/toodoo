class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :todo_task do |t|
      t.datetime :due_date
      t.string :task
      t.integer :todo_id
      t.boolean :finished, :default => false
      t.text :taskdescription
    end
  end

  def self.down
    drop_table :todo_tasks
  end
end
