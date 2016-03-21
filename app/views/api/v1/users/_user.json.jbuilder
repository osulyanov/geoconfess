json.id user.id
json.name user.name
json.surname user.surname
json.parish_id user.parish_id

if current_user == user || current_user.admin?
  json.active user.active
  json.role user.role
  json.email user.email
  json.phone user.phone
  json.notification user.notification
  json.newsletter user.newsletter
end
