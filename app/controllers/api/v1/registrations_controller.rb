class Api::V1::RegistrationsController < Api::V1::V1Controller

  resource_description do
    short 'User Registration'
  end

  api! 'Register user'
  description <<-EOS
        ## Description
        Users registration
        Returns code 201 with no content if user successfully created.
  EOS
  param :user, Hash, desc: 'User info' do
    param :role, ['priest', 'user'], desc: 'Role', required: true
    param :email, String, desc: 'Email', required: true
    param :password, String, desc: 'Password', required: true
    param :name, String, desc: 'Name', required: true
    param :surname, String, desc: 'Surname', required: true
    param :phone, /\+?\d{11}/, desc: 'Phone'
    param :notification, :bool, desc: 'Notification'
    param :newsletter, :bool, desc: 'Newsletter'
  end

  def create
    @user = User.new(user_params)
    @user.role = :user if @user.admin? # user can't register as admin via API
    if @user.save
      sign_in @user
      head status: :created
    else
      render status: :unprocessable_entity, json: { errors: @user.errors }
    end
  end

  private

  def user_params
    params.require(:user).permit(:role, :email, :password, :name, :surname,
                                 :phone, :notification, :newsletter)
  end
end
