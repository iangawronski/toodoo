require "toodoo/version"
require "toodoo/init_db"
require 'highline/import'
require 'pry'

module Toodoo
  class User < ActiveRecord::Base
    has_many :todo_lists
  end

  class List < ActiveRecord::Base
    has_many :todo_tasks
    belongs_to :user
  end

  class Task < ActiveRecord::Base
    has_one :todo_list
  end


end

class TooDooApp
  def initialize
    @user = nil
    @todos = nil
    @show_done = nil
  end

  def new_user
    say("Creating a new user:")
    name = ask("Username?") { |q| q.validate = /\A\w+\Z/ }
    @user = Toodoo::User.create(:name => name)
    say("We've created your account and logged you in. Thanks #{@user.name}!")
  end

  def login
    choose do |menu|
      menu.prompt = "Please choose an account: "

      Toodoo::User.find_each do |u|
        menu.choice(u.name, "Login as #{u.name}.") { @user = u }
      end

      menu.choice(:back, "Just kidding, back to main menu!") do
        say "You got it!"
        @user = nil
      end
    end
  end

  def delete_user
    choices = 'yn'
    delete = ask("Are you *sure* you want to stop using TooDoo?") do |q|
      q.validate =/\A[#{choices}]\Z/
      q.character = true
      q.confirm = true
    end
    if delete == 'y'
      @user.destroy
      @user = nil
    end
  end

  def new_todo_list
    say("Creating a new to do list name:")
    list_name = ask("What would you like the list name to be?") { |q| q.validate = /\A\w+\Z/ }
    @todos = Toodoo::List.create(:title => title, :user_id => user.id)
    say("Cangrats, #{@user.name} you have successfully created a new list called #{@todos.title}!" )
  end

  def pick_todo_list
    choose do |menu|
      menu.prompt = "Please pick one of your lists:"
        Toodoo::List.where(:user_id => user.id).find_each do |x|
          menu.choice(x.title, "Choose #{x.title}") { @todos = x }
      end
      menu.choice(:back, "Just kidding, back to the main menu!") do
        say "You got it!"
        @todos = nil
      end
    end
  end

  def delete_todo_list
    choose do |menu|
      menu.choice = "Please choose which list you would like to delete:"
        Toodoo::List.where(:user_id => user.id).find_each do |x|
          menu.choice(x.title, "Choose #{x.title}") {@todos = x}
      end
      choices = 'yn'
      delete = ask("Are you sure you want to delete #{x.title}?") do |q|
        q.validate =/\A[#{choices}]\Z/
        q.character = true
        q.confirm = true
      end
      if delete == 'y'
        @todos.destroy
        @todos = nil
      end
    end
  end

  def new_task
    say("New task:")
    task = ask("What is the new task name?") { |q| q.validate = /\A\w+\Z/ }
      Toodoo::Task.create{:task => task, :finished => false, :todo_id => todo.id}
  end

  ## NOTE: For the next 3 methods, make sure the change is saved to the database.
  def mark_done
    choose do |menu|
      menu.prompt = "Please select a choice:"
      Toodoo::Task.where(:todo_id => todo.id, :finished => false) do |y|
        menu.choice(y.task, "Task Completed") {y.update(:finished => true)}
        x.save
      end
      menu.choice(:back)
    end
  end

  def change_due_date
    choose do |menu|
      menu.prompt = "Please select a choice:"
        Toodoo::Task.where(:user_id => user.id).find_each do |x|
          menu.choice(x.title, "Choose #{x.title}") { @todos = x }
      end
      updated_due_date = ask("When would you like the new due date to be?", ###### )

      # HAVING ISSUES --> finish this sections after break...

    # say("Set new due date:")
    # due_date = ask("What would you like your due date to be for your task?") { |q| q.validate = /\A\w+\Z/ }
  end

  def edit_task
    choose do |menu|
      menu.prompt = "Which task would you like to edit?"
      Toodoo::Task.where(:todo_id => @todos.id).each do |x|
        menu.choice(x.name, "Yeah") {x.update(name: get_new_task_name)}
        x.save
      end
    end
  end

  def show_overdue
    @todos.task.order(:due_date :asc) do |task|
    say("These are your items, sorted by newest first.")
      if task.due_date < Date.today
        say("The task is overdue!")
      end
    end
  end

  def get_new_task_name
    puts "Please enter in a new name for your task."
    entry = gets.chomp!
    return entry
  end

  def run
    puts "Welcome to your personal TooDoo app."
    loop do
      choose do |menu|
        menu.layout = :menu_only
        menu.shell = true

        # Are we logged in yet?
        unless @user
          menu.choice(:new_user, "Create a new user.") { new_user }
          menu.choice(:login, "Login with an existing account.") { login }
        end

        # We're logged in. Do we have a todo list to work on?
        if @user && !@todos
          menu.choice(:delete_account, "Delete the current user account.") { delete_user }
          menu.choice(:new_list, "Create a new todo list.") { new_todo_list }
          menu.choice(:pick_list, "Work on an existing list.") { pick_todo_list }
          menu.choice(:remove_list, "Delete a todo list.") { delete_todo_list }
        end

        # Let's work on some todos!
        if @todos
          menu.choice(:new_task, "Add a new task.") { new_task }
          menu.choice(:mark_done, "Mark a task finished.") { mark_done }
          menu.choice(:move_date, "Change a task's due date.") { change_due_date }
          menu.choice(:edit_task, "Update a task's description.") { edit_task }
          menu.choice(:show_done, "Toggle display of tasks you've finished.") { @show_done = !!@show_done }
          menu.choice(:show_overdue, "Show a list of task's that are overdue, oldest first.") { show_overdue }
          menu.choice(:back, "Go work on another Toodoo list!") do
            say "You got it!"
            @todos = nil
          end
        end

        menu.choice(:quit, "Quit!") { exit }
      end
    end
  end
end

binding.pry

todos = TooDooApp.new
todos.run
