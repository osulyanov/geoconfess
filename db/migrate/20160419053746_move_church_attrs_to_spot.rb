class MoveChurchAttrsToSpot < ActiveRecord::Migration
  def change
    add_column :spots, :street, :string
    add_column :spots, :postcode, :string
    add_column :spots, :city, :string
    add_column :spots, :state, :string
    add_column :spots, :country, :string
  end
end
