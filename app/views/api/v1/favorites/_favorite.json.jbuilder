json.id favorite.id
json.priest do
  json.partial! 'api/v1/users/user_embedded', user: favorite.priest
end
