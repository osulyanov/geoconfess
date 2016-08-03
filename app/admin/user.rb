ActiveAdmin.register User do
  permit_params :name, :surname, :email, :phone, :role, :active, :notification,
                :newsletter, :celebret_url, :password, :password_confirmation,
                :os, :push_token, :notify_when_priests_around

  index do
    selectable_column
    id_column
    column :role
    column(:name) { |u| "#{u.name} #{u.surname}" }
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
      f.input :role, as: :select, collection: User.roles.keys
      f.input :celebret_url
      f.input :active
      f.input :notification
      f.input :notify_when_priests_around
      f.input :newsletter
      f.input :os, as: :select, collection: %w(ios android)
      f.input :push_token
      if f.object.new_record?
        f.input :password
        f.input :password_confirmation
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :encrypted_password
      row :reset_password_token
      row :reset_password_sent_at
      row :remember_created_at
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
      row :created_at
      row :updated_at
      row :role
      row :name
      row :surname
      row :phone
      row :notification
      row :newsletter
      row :active
      row :celebret_url do
        link_to(user.celebret_url, user.celebret_url, target: '_blank') if user.celebret_url.present?
      end
      row :os
      row :push_token
      row :pusher_socket_id
      row :notify_when_priests_around
    end
  end
end
