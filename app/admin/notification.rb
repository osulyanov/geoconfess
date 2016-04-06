ActiveAdmin.register Notification do
  permit_params :user_id, :notificationable_type, :notificationable_id, :unread

  scope :all, default: true
  scope 'Unread' do |items|
    items.unread
  end

  index do
    selectable_column
    id_column
    column :user
    column :notificationable
    column :unread
    column :created_at
    actions
  end

  filter :user
  filter :notificationable_type
  filter :notificationable_id

  form do |f|
    f.inputs 'Notification Details' do
      f.input :user
      f.input :notificationable_type, as: :select, collection: ['MeetRequest', 'Message']
      f.input :notificationable_id
      f.input :unread
    end
    f.actions
  end
end
