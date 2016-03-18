class Api::V1::PasswordsController < Api::V1::V1Controller
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
    params.require(:email)
  end
end
