json.id meet_request.id
json.priest_id meet_request.priest_id
json.status meet_request.status
json.penitent do
  if current_user.id == meet_request.priest_id
    json.partial! 'api/v1/users/user_embedded', user: meet_request.penitent
    json.latitude meet_request.latitude
    json.longitude meet_request.longitude
  else
    json.penitent_id meet_request.penitent_id
  end
end
