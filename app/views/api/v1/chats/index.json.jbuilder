json.array! @user_ids do |user_id|
  user = @users.select { |u| u.id == user_id }.first
  next unless user

  json.id user_id
  json.user do
    json.id user.id
    json.name user.name
    json.surname user.surname
  end
  json.last_message do
    last_message = current_user.messages.with_user(user.id).last
    json.partial! 'api/v1/messages/message', message: last_message
  end
end
