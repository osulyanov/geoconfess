require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'not valid without email' do
    subject.email = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without password' do
    subject.password = nil
    expect(subject).not_to be_valid
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
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_parish_id             (parish_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
