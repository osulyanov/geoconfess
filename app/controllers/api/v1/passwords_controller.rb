module Api
  module V1
    class PasswordsController < Api::V1::V1Controller
      resource_description do
        short 'User Password'
      end

      api :POST, '/v1/passwords', 'Send reset password instructions'
      description <<-EOS
        ## Description
        Sends reset password instruction on given email address.
        Returns code 201 if passwords instructions email successfully sent.
        Returns code 404 if user with given email doesn't exist.
        Returns code 400 if email doesn't present.
      EOS
      param :user, Hash, desc: 'User info', required: true do
        param :email, String, desc: 'Email', required: true
      end

      def create
        user = User.find_by(email: user_params)
        if user.present?
          user.send_reset_password_instructions
          head :created
        else
          head :not_found
        end
      end

      private

      def user_params
        params.require(:user).require(:email)
      end
    end
  end
end
