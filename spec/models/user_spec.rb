require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'not valid without role' do
    subject.role = nil

    expect(subject).not_to be_valid
  end

  it 'not valid without name' do
    subject.name = nil

    expect(subject).not_to be_valid
  end

  it 'not valid without surname' do
    subject.surname = nil

    expect(subject).not_to be_valid
  end

  it 'not valid without correct phone' do
    subject.phone = '123'

    expect(subject).not_to be_valid
  end

  it 'not valid without email' do
    subject.email = nil

    expect(subject).not_to be_valid
  end

  it 'not valid without password' do
    subject.password = nil

    expect(subject).not_to be_valid
  end

  it 'valid without os and push_token' do
    subject.os = nil
    subject.push_token = nil

    expect(subject).to be_valid
  end

  it 'not valid with wrong os' do
    subject.os = 'windowsphone'

    expect(subject).not_to be_valid
  end

  it 'not valid with push_token but without os' do
    subject.os = nil
    subject.push_token = '123456'

    expect(subject).not_to be_valid
  end

  describe '#display_name' do
    it 'returns the concatenated first and last name if both are present' do
      user = create(:user, name: 'Alex', surname: 'Pushkin')

      result = user.display_name

      expect(result).to eq('Alex Pushkin')
    end

    it 'returns name if name present but surname not' do
      user = build(:user, name: 'Alex', surname: '')

      result = user.display_name

      expect(result).to eq('Alex')
    end

    it 'returns surname if surname present but name not' do
      user = build(:user, name: '', surname: 'Pushkin')

      result = user.display_name

      expect(result).to eq('Pushkin')
    end

    it 'returns email if both name and surname not specified' do
      user = build(:user, email: 'em@il.ru', name: '', surname: '')

      result = user.display_name

      expect(result).to eq('em@il.ru')
    end
  end

  describe '#active_spot' do
    let(:user) { create(:user, role: :priest) }
    subject { user.active_spot }

    context 'not priest' do
      let(:user) { create(:user, role: :user) }
      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'without active spots' do
      let(:spot) { create(:spot, activity_type: :static, priest: user) }
      let!(:inactive_recurrence) { create(:recurrence, spot: spot, date: 1.day.ago) }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end

    context 'with active dynamic spot' do
      let(:spot) { create(:spot, activity_type: :static, priest: user) }
      let!(:recurrence) { create(:recurrence, spot: spot,
                                 date: Time.zone.today,
                                 active_date: Time.zone.today) }


      it 'returns active recurrence' do
        expect(subject).to eq(spot)
      end
    end

    context 'with active static spot' do
      let!(:spot) { create(:spot, activity_type: :dynamic, priest: user) }

      it 'returns active recurrence' do
        expect(subject).to eq(spot)
      end
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
#  pusher_socket_id       :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_parish_id             (parish_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
