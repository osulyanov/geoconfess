ActiveAdmin.register User do
  permit_params :name, :surname, :email, :phone, :parish_id, :role, :active,
                :notification, :newsletter,
                :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :role
    column(:name) { |u| "#{u.name} #{u.surname}" }
    column :parish
    column :email
    column :active
    column :created_at
    actions
  end

  filter :email
  filter :role

  form do |f|
    f.inputs 'User Details' do
      f.input :name
      f.input :surname
      f.input :email
      f.input :phone
      f.input :parish, as: :select, collection: Parish.all
      f.input :role, as: :select, collection: User.roles.keys
      f.input :active
      f.input :notification
      f.input :newsletter
      if f.object.new_record?
        f.input :password
        f.input :password_confirmation
      end
    end
    f.actions
  end
end
