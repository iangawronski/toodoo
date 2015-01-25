class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :todo_tasks do |t|
      t.datetime :due_date
      t.string :task
      t.integer :task_list_id
      t.boolean :completed, :default => false
      t.text :taskdescription
    end
  end

  def self.down
    drop_table :todo_tasks
  end
end
