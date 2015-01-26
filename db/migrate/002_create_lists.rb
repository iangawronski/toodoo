class CreateList < ActiveRecord:Migration
  def self.up
    create_table :todo_list do |t|
      t.string :title
      t.integer :user_id
    end
  end

  def self.down
    drop_table :todo_list
  end
end
