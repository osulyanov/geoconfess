ActiveAdmin.register Spot do
  permit_params :name, :priest_id, :church_id, :activity_type,
                :latitude, :longitude, recurrence_attributes: []

  index do
    selectable_column
    id_column
    column :name
    column :activity_type
    column :priest
    column :church
    column :created_at
    actions
  end

  filter :activity_type
  filter :name
  filter :priest
  filter :church

  form do |f|
    f.inputs 'Spot Details' do
      f.input :name
      f.input :activity_type, as: :select, collection: Spot.activity_types.keys
      f.input :priest, as: :select, collection: User.priest
      f.input :church
      f.inputs 'For dynamic only' do
        f.input :latitude
        f.input :longitude
      end
    end
    f.actions
  end
end
