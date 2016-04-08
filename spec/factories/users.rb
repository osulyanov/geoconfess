FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "user_#{n}@mysite.com"
    end
    password '123password%'
    role :user
    name 'Pavel'
    surname 'Durov'
    phone '+1234567890'
    active true
    os 'ios'
    push_token '76312362136213128732444'

    trait :admin do
      name 'Admin'
      role :admin
    end
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
#  celebret_url           :string
#  os                     :string
#  push_token             :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_parish_id             (parish_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
