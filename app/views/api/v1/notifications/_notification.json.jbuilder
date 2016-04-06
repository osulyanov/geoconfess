json.id notification.id
json.unread notification.unread
json.model notification.notificationable_type
json.action notification.action
case notification.notificationable_type
  when 'MeetRequest'
    json.meet_request do
      json.partial! 'api/v1/meet_requests/meet_request', meet_request: notification.notificationable
    end
  when 'Message'

end
