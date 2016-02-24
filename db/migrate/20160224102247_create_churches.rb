class CreateChurches < ActiveRecord::Migration
  def change
    create_table :churches do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.string :street
      t.string :postcode
      t.string :city
      t.string :state
      t.string :country
      t.timestamps null: false
    end
  end
end
