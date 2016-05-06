json.id favorite.id
json.priest do
  json.partial! 'api/v1/users/user_embedded_with_location',
                user: favorite.priest
end
