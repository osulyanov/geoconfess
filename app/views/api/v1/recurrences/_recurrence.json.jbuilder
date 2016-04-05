json.id recurrence.id
json.spot_id recurrence.spot_id
json.start_at recurrence.start_at.strftime('%H:%M')
json.stop_at recurrence.stop_at.strftime('%H:%M')
if recurrence.date.present?
  json.date recurrence.date
else
  json.week_days recurrence.week_days
end
