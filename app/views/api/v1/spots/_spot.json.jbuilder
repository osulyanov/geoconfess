json.id spot.id
json.name spot.name
json.church_id spot.church_id
json.activity_type spot.activity_type
if spot.dynamic?
  json.latitude spot.latitude
  json.longitude spot.longitude
elsif spot.church
  json.latitude spot.church.latitude
  json.longitude spot.church.longitude
end
unless params[:me]
  json.priest do
    json.partial! 'api/v1/users/user_embedded', user: spot.priest
  end
end
json.recurrences spot.recurrences do |recurrence|
  json.id recurrence.id
  json.date recurrence.date
  json.start_at recurrence.start_at.strftime('%H:%M')
  json.stop_at recurrence.stop_at.strftime('%H:%M')
  json.week_days recurrence.week_days
end
