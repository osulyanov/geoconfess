module Api
  class ApiController < ApplicationController
    protect_from_forgery with: :null_session,
                         if: proc { |c| c.request.format.json? }
    respond_to :json

    helper_method :current_user

    def access_denied(exception)
      message = exception.message || 'Access Denied'
      render json: { message: message }, status: 401
    end

    private

    def current_user
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end
  end
end
