ActiveAdmin.register Message do
  permit_params :sender_id, :recipient_id, :text

  index do
    selectable_column
    id_column
    column :sender
    column :recipient
    column(:text) { |m| truncate m.text, length: 100 }
    column :created_at
    actions
  end

  filter :sender
  filter :recipient
  filter :text
  filter :longitude

  form do |f|
    f.inputs 'Message Details' do
      f.input :sender, as: :select, collection: User.all.collection_for_admin
      f.input :recipient, as: :select, collection: User.all.collection_for_admin
      f.input :text
    end
    f.actions
  end
end
