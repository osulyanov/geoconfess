json.id spot.id
json.name spot.name
json.activity_type spot.activity_type
json.latitude spot.latitude
json.longitude spot.longitude
if spot.static?
  json.church do
    json.partial! 'api/v1/churches/church', church: spot.church
  end
  json.recurrences spot.recurrences do |recurrence|
    json.partial! 'api/v1/recurrences/recurrence', recurrence: recurrence
  end
end
unless params[:me]
  json.priest do
    json.partial! 'api/v1/users/user_embedded', user: spot.priest
  end
end
