class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user, index: true
      t.references :notificationable, polymorphic: true, index: { name: 'index_notifs_on_notifable_type_and_notifable_id' }
      t.boolean :unread, null: false, default: true

      t.timestamps null: false
    end
  end
end
