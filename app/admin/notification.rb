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
    column :action
    column :notificationable
    column :unread
    column(:text) { |n| truncate n.text, length: 50 }
    column :created_at
    actions
  end

  filter :user
  filter :action, as: :select, collection: Notification.all.pluck(:action).uniq
  filter :notificationable_type
  filter :notificationable_id

  form do |f|
    f.inputs 'Notification Details' do
      f.input :user
      f.input :action
      f.input :notificationable_type, as: :select, collection: ['MeetRequest', 'Message']
      f.input :notificationable_id
      f.input :unread
      f.input :text
    end
    f.actions
  end
end
