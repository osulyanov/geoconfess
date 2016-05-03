ActiveAdmin.register Spot do
  permit_params :name, :priest_id, :activity_type,
                :latitude, :longitude, :street, :postcode, :city, :state,
                :country, recurrence_attributes: []

  index do
    selectable_column
    id_column
    column :name
    column :activity_type
    column :priest
    column(:address) { |c| [c.street, c.postcode, c.city, c.country].select(&:present?).join ', ' }
    column :created_at
    actions
  end

  filter :activity_type
  filter :name
  filter :priest

  form do |f|
    f.inputs 'Spot Details' do
      f.input :name
      f.input :activity_type, as: :select, collection: Spot.activity_types.keys
      f.input :priest, as: :select, collection: User.priest
      f.input :latitude
      f.input :longitude
      f.input :street
      f.input :postcode
      f.input :city
      f.input :state
      f.input :country, priority_countries: %w(FR GB DE)
    end
    f.actions
  end
end
