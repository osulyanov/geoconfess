ActiveAdmin.register Church do
  permit_params :name, :latitude, :longitude, :street, :postcode, :city, :state,
                :country

  index do
    selectable_column
    id_column
    column :name
    column :latitude
    column :longitude
    column(:address) { |c| [c.street, c.postcode, c.city, c.country].select(&:present?).join ', ' }
    column :created_at
    actions
  end

  filter :name
  filter :latitude
  filter :longitude

  form do |f|
    f.inputs 'Church Details' do
      f.input :name
      f.input :latitude
      f.input :longitude
      f.input :street
      f.input :postcode
      f.input :city
      f.input :state
      f.input :country, priority_countries: ['FR', 'GB', 'DE']
    end
    f.actions
  end
end
