class UsersAddPusherSocketId < ActiveRecord::Migration
  def change
    add_column :users, :pusher_socket_id, :string
  end
end
