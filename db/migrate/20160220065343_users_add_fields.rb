class UsersAddFields < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :surname, :string
    add_column :users, :phone, :string
    add_column :users, :notification, :boolean, null: false, default: false
    add_column :users, :newsletter, :boolean, null: false, default: false
    add_column :users, :active, :boolean, null: false, default: false
  end
end
