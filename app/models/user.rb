class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: [:admin, :priest, :user]

  has_many :tokens, class_name: 'Doorkeeper::AccessToken',
           foreign_key: 'resource_owner_id', dependent: :destroy
end
