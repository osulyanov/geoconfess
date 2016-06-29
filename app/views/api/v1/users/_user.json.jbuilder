json.id user.id
json.name user.name
json.surname user.surname

if current_user == user || current_user.admin?
  json.active user.active
  json.role user.role
  json.email user.email
  json.phone user.phone
  json.notification user.notification
  json.notify_when_priests_around user.notify_when_priests_around
  json.newsletter user.newsletter
end
