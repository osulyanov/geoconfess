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
json.priest do
  json.partial! 'api/v1/users/user_embedded', user: spot.priest
end
