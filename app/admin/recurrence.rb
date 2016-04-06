ActiveAdmin.register Recurrence do
  permit_params :spot_id, :date, :start_at, :stop_at, :days, week_days: []

  index do
    selectable_column
    id_column
    column :spot
    column :date
    column(:days) { |r| r.week_days.join ', ' }
    column(:time) { |r| "#{r.start_at.strftime('%H:%M')}–#{r.stop_at.strftime('%H:%M')}" }
    column :created_at
    actions
  end

  filter :spot
  filter :date

  form do |f|
    f.inputs 'Recurrence Details' do
      f.input :spot
      f.input :date
      f.input :start_at
      f.input :stop_at
      # f.input :days, as: :number
      f.input :week_days, as: :check_boxes, collection: Date::DAYNAMES
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :spot_id
      row :date
      row(:start_at) { |r| r.start_at.strftime('%H:%M') }
      row(:stop_at) { |r| r.stop_at.strftime('%H:%M') }
      row(:days) { |r| r.week_days.join ', ' }
      row :created_at
      row :updated_at
    end
  end
end
