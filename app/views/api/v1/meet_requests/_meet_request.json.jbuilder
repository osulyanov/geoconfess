json.id meet_request.id
json.status meet_request.status
json.penitent do
  if current_user.id == meet_request.penitent_id
    json.id meet_request.penitent_id
  else
    json.partial! 'api/v1/users/user_embedded', user: meet_request.penitent
    json.latitude meet_request.latitude
    json.longitude meet_request.longitude
  end
end
json.priest do
  if current_user.id == meet_request.priest_id
    json.id meet_request.priest_id
  else
    json.partial! 'api/v1/users/user_embedded', user: meet_request.priest
  end
end
