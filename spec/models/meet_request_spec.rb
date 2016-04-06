require 'rails_helper'

RSpec.describe MeetRequest, type: :model do
  let (:parish) { create(:parish) }
  let (:priest) { create(:user, role: :priest, parish: parish) }
  let (:penitent) { create(:user, role: :user) }
  subject { build(:meet_request, priest: priest, penitent: penitent) }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'not valid without priest' do
    subject.priest = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without penitent' do
    subject.penitent = nil
    expect(subject).not_to be_valid
  end

  context 'after create' do
    before do
      subject.save
    end
    let (:notification) { subject.notification }

    it 'creates notification' do
      expect(notification).to be_persisted
    end

    context 'with attributes' do
      it 'unread is true' do
        expect(notification).to be_unread
      end

      it 'user eq to priest' do
        expect(notification.user_id).to eq(priest.id)
      end

      it 'notificationable_type eq to MeetRequest' do
        expect(notification.notificationable_type).to eq('MeetRequest')
      end

      it 'notificationable_id eq to ID of just created meet request' do
        expect(notification.notificationable_id).to eq(subject.id)
      end
    end
  end
end

# == Schema Information
#
# Table name: meet_requests
#
#  id          :integer          not null, primary key
#  priest_id   :integer
#  penitent_id :integer
#  status      :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  params      :hstore           default({}), not null
#
# Indexes
#
#  index_meet_requests_on_penitent_id  (penitent_id)
#  index_meet_requests_on_priest_id    (priest_id)
#
