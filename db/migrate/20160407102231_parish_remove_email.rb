class ParishRemoveEmail < ActiveRecord::Migration
  def change
    remove_column :parishes, :email, :string
  end
end
