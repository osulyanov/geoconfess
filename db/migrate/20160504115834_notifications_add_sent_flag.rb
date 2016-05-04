class NotificationsAddSentFlag < ActiveRecord::Migration
  def change
    add_column :notifications, :sent, :boolean, null: false, default: false
  end
end
