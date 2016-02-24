ActiveAdmin.register MeetRequest do
  permit_params :priest_id, :penitent_id, :status

  index do
    selectable_column
    id_column
    column :priest
    column :penitent
    column :status
    column :created_at
    actions
  end

  filter :priest
  filter :penitent
  filter :status

  form do |f|
    f.inputs 'MeetRequest Details' do
      f.input :priest, as: :select, collection: User.priest
      f.input :penitent
      f.input :status, as: :select, collection: MeetRequest.statuses.keys
    end
    f.actions
  end
end
