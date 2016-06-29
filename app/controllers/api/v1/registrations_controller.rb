module Api
  module V1
    class RegistrationsController < Api::V1::V1Controller
      resource_description do
        short 'User Registration'
      end

      api! 'Register user'
      description <<-EOS
        ## Description
        Users registration
        Returns code 201 and {result: "success"} if user successfully created and errors otherwise.
      EOS
      param :user, Hash, desc: 'User info', required: true do
        param :role, %w(priest user), desc: 'Role', required: true
        param :email, String, desc: 'Email', required: true
        param :password, String, desc: 'Password', required: true
        param :name, String, desc: 'Name', required: true
        param :surname, String, desc: 'Surname', required: true
        param :celebret_url, String, desc: 'Celebret URL'
        param :phone, /\+?\d{10,11}/, desc: 'Phone'
        param :notification, :bool, desc: 'Notification'
        param :notify_when_priests_around, :bool,
              desc: 'Notifications about priests around'
        param :newsletter, :bool, desc: 'Newsletter'
      end

      # rubocop:disable Metrics/MethodLength
      def create
        @user = User.new(user_params)
        # user can't register as admin via API
        @user.role = :user if @user.admin?
        @user.active = true unless @user.priest?
        if @user.save
          sign_in @user
          @user.send_welcome_message
          render status: :created, json: { result: 'success' }
        else
          render status: :unprocessable_entity,
                 json: { result: 'failed', errors: @user.errors }
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      def user_params
        params.require(:user)
              .permit(:role, :email, :password, :name, :surname, :phone,
                      :notification, :newsletter, :celebret_url,
                      :notify_when_priests_around)
      end
    end
  end
end
