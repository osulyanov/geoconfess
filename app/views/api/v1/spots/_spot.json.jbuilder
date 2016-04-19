json.id spot.id
json.name spot.name
json.activity_type spot.activity_type
json.latitude spot.latitude
json.longitude spot.longitude
if spot.static?
  json.street spot.street
  json.postcode spot.postcode
  json.city spot.city
  json.state spot.state
  json.country spot.country
  json.recurrences spot.recurrences do |recurrence|
    json.partial! 'api/v1/recurrences/recurrence', recurrence: recurrence
  end
end
unless params[:me]
  json.priest do
    json.partial! 'api/v1/users/user_embedded', user: spot.priest
  end
end
