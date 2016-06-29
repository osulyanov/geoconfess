class UsersAddNotifyWhenPriestsAround < ActiveRecord::Migration
  def change
    add_column :users, :notify_when_priests_around, :boolean, null: false,
                                                              default: true
  end
end
