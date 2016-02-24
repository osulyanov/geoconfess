class CreateMeetRequests < ActiveRecord::Migration
  def change
    create_table :meet_requests do |t|
      t.references :priest, index: true
      t.references :penitent, index: true
      t.integer :status, null: false, default: 0

      t.timestamps null: false
    end
  end
end
