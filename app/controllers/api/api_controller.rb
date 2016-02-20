module Api
  class ApiController < ApplicationController
    protect_from_forgery with: :null_session,
                         if: proc { |c| c.request.format.json? }

    helper_method :current_user

    resource_description do
      formats [:json]
      error 400, 'Bad Request'
      error 404, 'Missing'
      error 500, 'Server crashed for some reason',
            meta: { anything: 'you can think of' }
    end

    rescue_from Apipie::ParamMissing do |e|
      render json: { 'ErrorType' => 'Validation Error',
                     'message' => e.message },
             status: :bad_request
    end

    rescue_from Apipie::ParamInvalid do |e|
      render json: { 'ErrorType' => 'Validation Error',
                     'message' => e.message },
             status: :bad_request
    end

    rescue_from ArgumentError do |e|
      render json: { 'ErrorType' => 'Validation Error',
                     'message' => e.message },
             status: :bad_request
    end

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
