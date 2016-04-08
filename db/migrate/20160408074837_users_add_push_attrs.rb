class UsersAddPushAttrs < ActiveRecord::Migration
  def change
    add_column :users, :os, :string
    add_column :users, :push_token, :string
  end
end
