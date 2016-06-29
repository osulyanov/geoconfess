class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: [:admin, :priest, :user]

  has_many :tokens, class_name: 'Doorkeeper::AccessToken',
                    foreign_key: 'resource_owner_id', dependent: :destroy
  has_many :spots, foreign_key: 'priest_id', dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :outbound_requests, class_name: 'MeetRequest',
                               foreign_key: 'penitent_id', dependent: :destroy

  scope :priests, -> { where role: roles[:priest] }
  scope :active, -> { where active: true }

  validates :role, presence: true
  validates :name, presence: true
  validates :surname, presence: true
  validates :phone, format: { with: /\A\+?\d{10,11}\z/ }, if: 'phone.present?'
  validates :os, inclusion: { in: %w(ios android) }, if: 'os.present?'
  validates :os, presence: true, if: 'push_token.present?'

  def self.collection_for_admin
    order(:id).map { |u| ["#{u.id}. #{u.display_name}", u.id] }
  end

  def display_name
    if name.present? || surname.present?
      return [name, surname].select(&:present?).join(' ')
    end
    email
  end

  def messages
    Message.with_user(id)
  end

  # rubocop:disable Metrics/AbcSize
  def chats
    chats = messages.select('DISTINCT ON (sender_id, recipient_id) *')
    chats.to_a.sort! { |f, s| s.created_at <=> f.created_at }
    @user_ids = []
    chats.each do |chat|
      next if @user_ids.include?(chat.sender_id)
      @user_ids.push(chat.sender_id) unless id == chat.sender_id
      @user_ids.push(chat.recipient_id) unless id == chat.recipient_id
    end
    @user_ids
  end
  # rubocop:enable Metrics/AbcSize

  def send_welcome_message
    UserMailer.registered(id).deliver_now
  end

  def channel
    "private-#{id}"
  end

  def active_spot
    return nil unless priest?
    spots.find_by(activity_type: Spot.activity_types[:dynamic]) ||
      spots.now.first
  end
end

# == Schema Information
#
# Table name: users
#
#  id                         :integer          not null, primary key
#  email                      :string           default(""), not null
#  encrypted_password         :string           default(""), not null
#  reset_password_token       :string
#  reset_password_sent_at     :datetime
#  remember_created_at        :datetime
#  sign_in_count              :integer          default(0), not null
#  current_sign_in_at         :datetime
#  last_sign_in_at            :datetime
#  current_sign_in_ip         :inet
#  last_sign_in_ip            :inet
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  role                       :integer
#  name                       :string
#  surname                    :string
#  phone                      :string
#  notification               :boolean          default(TRUE), not null
#  newsletter                 :boolean          default(FALSE), not null
#  active                     :boolean          default(FALSE), not null
#  celebret_url               :string
#  os                         :string
#  push_token                 :string
#  pusher_socket_id           :string
#  notify_when_priests_around :boolean          default(TRUE), not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
