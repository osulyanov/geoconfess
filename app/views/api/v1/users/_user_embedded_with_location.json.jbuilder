json.id user.id
json.name user.name
json.surname user.surname
spot = user.active_spot
if spot
  json.latitude spot.latitude
  json.longitude spot.longitude
end
