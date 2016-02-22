ActiveAdmin.register User do
  permit_params :name, :surname, :email, :phone, :parish_id, :role,
                :password, :password_confirmation

  index do
    selectable_column
    id_column
    column(:name) { |u| "#{u.name} #{u.surname}" }
    column :parish
    column :email
    column :role
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :role
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs 'User Details' do
      f.input :name
      f.input :surname
      f.input :email
      f.input :phone
      f.input :parish, as: :select, collection: Parish.all
      f.input :role, as: :select, collection: User.roles.keys
      if f.object.new_record?
        f.input :password
        f.input :password_confirmation
      end
    end
    f.actions
  end
end
