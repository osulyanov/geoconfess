json.array! @recurrences do |recurrence|
  json.name recurrence.spot.name
  json.start_at recurrence.start_at.strftime('%H:%M')
  json.stop_at recurrence.stop_at.strftime('%H:%M')
  if recurrence.date.present?
    json.date recurrence.date.strftime('%d/%m/%Y')
  else
    json.week_days recurrence.week_days_fr.join(', ')
  end
end
