ActiveAdmin.register MeetRequest do
  permit_params :priest_id, :penitent_id, :status, :latitude, :longitude

  scope :all, default: true
  scope 'Active' do |items|
    items.active
  end

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
      f.input :latitude
      f.input :longitude
    end
    f.actions
  end
end
