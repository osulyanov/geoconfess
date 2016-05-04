ActiveAdmin.register Favorite do
  permit_params :priest_id, :user_id

  index do
    selectable_column
    id_column
    column :user
    column :priest
    column :created_at
    actions
  end

  filter :user
  filter :priest

  form do |f|
    f.inputs 'Favorite Details' do
      f.input :user, as: :select, collection: User.all
      f.input :priest, as: :select, collection: User.priest
    end
    f.actions
  end
end
