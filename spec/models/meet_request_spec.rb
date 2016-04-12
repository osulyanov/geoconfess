require 'rails_helper'

RSpec.describe MeetRequest, type: :model do
  let (:priest) { create(:user, role: :priest) }
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

  context 'creates notification to priest' do
    before do
      subject.save
    end
    let (:notification_to_priest) { subject.notifications.find_by(user_id: priest.id) }

    it 'persisted' do
      expect(notification_to_priest).to be_persisted
    end

    context 'with attributes' do
      it 'received is received' do
        expect(notification_to_priest.action).to eq('received')
      end

      it 'unread is true' do
        expect(notification_to_priest).to be_unread
      end

      it 'notificationable_type eq to MeetRequest' do
        expect(notification_to_priest.notificationable_type).to eq('MeetRequest')
      end

      it 'notificationable_id eq to ID of just created meet request' do
        expect(notification_to_priest.notificationable_id).to eq(subject.id)
      end
    end
  end

  context 'creates notification to penitent' do
    before do
      subject.save
    end
    let (:notification_to_penitent) { subject.notifications.find_by(user_id: penitent.id) }

    it 'persisted' do
      expect(notification_to_penitent).to be_persisted
    end

    context 'with attributes' do
      it 'received is sent' do
        expect(notification_to_penitent.action).to eq('sent')
      end

      it 'unread is true' do
        expect(notification_to_penitent).to be_unread
      end

      it 'notificationable_type eq to MeetRequest' do
        expect(notification_to_penitent.notificationable_type).to eq('MeetRequest')
      end

      it 'notificationable_id eq to ID of just created meet request' do
        expect(notification_to_penitent.notificationable_id).to eq(subject.id)
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
