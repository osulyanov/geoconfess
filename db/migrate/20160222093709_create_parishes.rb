class CreateParishes < ActiveRecord::Migration
  def change
    create_table :parishes do |t|
      t.string :name
      t.string :email

      t.timestamps null: false
    end
  end
end
