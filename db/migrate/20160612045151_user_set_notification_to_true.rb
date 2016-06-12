class UserSetNotificationToTrue < ActiveRecord::Migration
  def change
    change_column_default :users, :notification, true
  end
end
