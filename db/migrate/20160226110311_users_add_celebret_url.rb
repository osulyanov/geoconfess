class UsersAddCelebretUrl < ActiveRecord::Migration
  def change
    add_column :users, :celebret_url, :string
  end
end
