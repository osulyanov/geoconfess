json.id meet_request.id
json.priest_id meet_request.priest_id
json.penitent_id meet_request.penitent_id
json.status meet_request.status
if current_user.id == meet_request.priest_id
  json.latitude meet_request.latitude
  json.longitude meet_request.longitude
end
