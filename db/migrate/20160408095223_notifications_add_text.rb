class NotificationsAddText < ActiveRecord::Migration
  def change
    add_column :notifications, :text, :string
  end
end
