module Api
  class ApiController < ApplicationController
    protect_from_forgery with: :null_session,
                         if: proc { |c| c.request.format.json? }
    respond_to :json

    helper_method :current_user

    rescue_from CanCan::AccessDenied, with: :access_denied

    rescue_from ActiveRecord::RecordNotFound, with: :not_found

    private

    def current_user
      User.find_by(id: doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def access_denied(exception)
      message = exception.message || 'Access Denied'
      render json: { message: message }, status: 401
    end

    def not_found(exception)
      message = exception.message || 'Not found'
      render json: { message: message }, status: 404
    end
  end
end
