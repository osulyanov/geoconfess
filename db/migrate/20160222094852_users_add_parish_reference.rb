class UsersAddParishReference < ActiveRecord::Migration
  def change
    add_reference :users, :parish, index: true
  end
end
