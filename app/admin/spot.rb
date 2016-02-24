ActiveAdmin.register Spot do
  permit_params :name, :priest_id, :church_id, recurrence_attributes: []

  index do
    selectable_column
    id_column
    column :name
    column :priest
    column :church
    column :created_at
    actions
  end

  filter :name
  filter :priest
  filter :church

  form do |f|
    f.inputs 'Spot Details' do
      f.input :name
      f.input :priest, as: :select, collection: User.priest
      f.input :church
    end
    f.actions
  end
end
