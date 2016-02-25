class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: [:admin, :priest, :user]

  has_many :tokens, class_name: 'Doorkeeper::AccessToken',
           foreign_key: 'resource_owner_id', dependent: :destroy
  has_many :spots, foreign_key: 'priest_id', dependent: :destroy
  belongs_to :parish
  accepts_nested_attributes_for :parish

  validates :role, presence: true
  validates :name, presence: true
  validates :surname, presence: true
  validates :phone, format: { with: /\A\+?\d{10,11}\z/ }, if: 'phone.present?'
  validates :parish, presence: true, if: 'priest?'

  def display_name
    return [name, surname].join(' ') if name.present? || surname.present?
    email
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  role                   :integer
#  name                   :string
#  surname                :string
#  phone                  :string
#  notification           :boolean          default(FALSE), not null
#  newsletter             :boolean          default(FALSE), not null
#  active                 :boolean          default(FALSE), not null
#  parish_id              :integer
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_parish_id             (parish_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
