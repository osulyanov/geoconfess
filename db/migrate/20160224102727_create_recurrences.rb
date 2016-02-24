class CreateRecurrences < ActiveRecord::Migration
  def change
    create_table :recurrences do |t|
      t.references :spot, index: true
      t.date :date
      t.time :start_at
      t.time :stop_at
      t.integer :days, null: false, default: 0

      t.timestamps null: false
    end
  end
end
