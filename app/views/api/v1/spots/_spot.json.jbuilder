json.id spot.id
json.name spot.name
json.activity_type spot.activity_type
if spot.dynamic?
  json.latitude spot.latitude
  json.longitude spot.longitude
elsif spot.church
  json.church_id spot.church_id
  json.latitude spot.church.latitude
  json.longitude spot.church.longitude
  json.recurrences spot.recurrences do |recurrence|
    json.partial! 'api/v1/recurrences/recurrence', recurrence: recurrence
  end
end
unless params[:me]
  json.priest do
    json.partial! 'api/v1/users/user_embedded', user: spot.priest
  end
end