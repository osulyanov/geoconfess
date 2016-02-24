ActiveAdmin.register Recurrence do
  permit_params :spot_id, :date, :start_at, :stop_at, :days, week_days: []

  index do
    selectable_column
    id_column
    column :spot
    column :date
    column(:days) { |r| r.days.to_a.join ', ' }
    column(:time) { |r| "#{r.start_at.strftime('%H:%M')}–#{r.stop_at.strftime('%H:%M')}" }
    column(:stop_at) { |r| "#{r.stop_at}" }
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
end
