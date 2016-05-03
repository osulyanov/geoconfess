class Api::V1::CredentialsController < Api::V1::V1Controller
  before_action :doorkeeper_authorize!
  before_action :set_user

  resource_description do
    short 'Current user'
  end

  api :GET, '/v1/me', 'Show current user'
  description <<-EOS
    ## Description
    Show data of current user
  EOS
  example <<-EOS
    {
      "id": 1,
      "name": "Oleg",
      "surname": "Sulyanov",
      "active": false,
      "role": "admin",
      "email": "admin@example.com",
      "phone": "+79134399113",
      "notification": false,
      "newsletter": false
    }
  EOS

  def show
    render 'api/v1/users/show'
  end

  api :PUT, '/v1/me', 'Update current user'
  description <<-EOS
    ## Description
    Updates current user
    Returns code 200 and {result: "success"} if user successfully updated.
  EOS
  param :user, Hash, desc: 'User info', required: true do
    param :email, String, desc: 'Email', required: true
    param :password, String, desc: 'Password', required: true
    param :name, String, desc: 'Name', required: true
    param :surname, String, desc: 'Surname', required: true
    param :phone, /\+?\d{10,11}/, desc: 'Phone'
    param :notification, :bool, desc: 'Notification'
    param :newsletter, :bool, desc: 'Newsletter'
  end

  def update
    if @user.update_attributes(user_params)
      render status: :ok, json: { result: 'success' }
    else
      render status: :unprocessable_entity, json: { errors: @user.errors }
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :name, :surname,
                                 :phone, :notification, :newsletter)
  end

  def set_user
    @user = current_user
  end
end
