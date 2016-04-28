json.id user.id
json.name user.name
json.surname user.surname
if spot = user.active_spot
  json.latitude spot.latitude
  json.longitude spot.longitude
end
