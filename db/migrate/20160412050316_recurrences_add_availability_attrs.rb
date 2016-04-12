class RecurrencesAddAvailabilityAttrs < ActiveRecord::Migration
  def change
    add_column :recurrences, :active_date, :date
    add_column :recurrences, :busy_count, :integer, null: false, default: 0
  end
end
