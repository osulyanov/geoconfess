class Api::V1::UsersController < Api::V1::V1Controller
  before_action :doorkeeper_authorize!
  load_and_authorize_resource
  before_action :set_user

  resource_description do
    short 'Users'
  end

  api! 'Show user'
  description <<-EOS
    ## Description
    Show user data
  EOS
  example <<-EOS
    {
      "id": 1,
      "name": "Oleg",
      "surname": "Sulyanov",
      "parish_id": 1,
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


  api! 'Update user'
  description <<-EOS
    ## Description
    Updates user data
    Returns code 200 with no content if user successfully updated.
  EOS
  param :user, Hash, desc: 'User info' do
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
      head status: :ok
    else
      render status: :unprocessable_entity, json: { errors: @user.errors }
    end
  end


  api! 'Destroy user'
  description <<-EOS
    ## Description
    Destroys the user with all associated spots
    Returns code 200 with no content if user successfully destroyed.
  EOS

  def destroy
    if @user.destroy
      head status: :ok
    else
      render status: :unprocessable_entity, json: { errors: @user.errors }
    end
  end


  api! 'Activate user'
  description <<-EOS
    ## Description
    Sets user.active to true
    Returns code 200 with no content if user successfully updated.
  EOS

  def activate
    if @user.update_attribute(:active, true)
      head status: :ok
    else
      render status: :unprocessable_entity, json: { errors: @user.errors }
    end
  end


  api! 'Deactivate user'
  description <<-EOS
    ## Description
    Sets user.active to false
    Returns code 200 with no content if user successfully updated.
  EOS

  def deactivate
    if @user.update_attribute(:active, false)
      head status: :ok
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
    @user = User.find(params[:id])
  end
end
