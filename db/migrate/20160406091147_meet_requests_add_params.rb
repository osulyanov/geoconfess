class MeetRequestsAddParams < ActiveRecord::Migration
  def change
    enable_extension :hstore
    add_column :meet_requests, :params, :hstore, default: '', null: false
  end
end
