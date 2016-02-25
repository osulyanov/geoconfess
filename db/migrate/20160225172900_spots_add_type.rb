class SpotsAddType < ActiveRecord::Migration
  def change
    add_column :spots, :activity_type, :integer, null: false, default: 0
  end
end
