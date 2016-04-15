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

  it 'not valid without latitude' do
    subject.latitude = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without longitude' do
    subject.longitude = nil
    expect(subject).not_to be_valid
  end

  describe '.active' do
    it 'returns requests created less than 1 day ago' do
      request_23_h_ago = create(:meet_request, priest: priest, penitent: penitent, created_at: 23.hours.ago)

      result = MeetRequest.active

      expect(result).to include(request_23_h_ago)
    end

    it 'doesn\'t return requests created more than 1 day ago' do
      request_25_h_ago = create(:meet_request, priest: priest, penitent: penitent, created_at: 25.hours.ago)

      result = MeetRequest.active

      expect(result).not_to include(request_25_h_ago)
    end
  end

  describe '.for_user' do
    let (:priest) { create(:user, role: :priest) }
    let (:penitent) { create(:user, role: :user) }
    let (:other_user) { create(:user, role: :user) }
    let! (:meet_request) { create(:meet_request, priest: priest, penitent: penitent) }

    it 'returns requests to user' do
      result = MeetRequest.for_user(priest.id)

      expect(result).to include(meet_request)
    end

    it 'returns requests from user' do
      result = MeetRequest.for_user(penitent.id)

      expect(result).to include(meet_request)
    end

    it 'doesn\'t return requests of other user' do
      result = MeetRequest.for_user(other_user.id)

      expect(result).not_to include(meet_request)
    end
  end

  context 'after creation' do
    describe 'creates notification to priest' do
      before do
        subject.save
      end

      let (:notification_to_priest) { subject.notifications.find_by(user_id: priest.id) }

      it 'present' do
        expect(notification_to_priest).to be_present
      end

      context 'with attributes' do
        it 'action is received' do
          expect(notification_to_priest.action).to eq('received')
        end

        it 'unread is true' do
          expect(notification_to_priest).to be_unread
        end
      end
    end

    describe 'creates notification to penitent' do
      before do
        subject.save
      end

      let (:notification_to_penitent) { subject.notifications.find_by(user_id: penitent.id) }

      it 'present' do
        expect(notification_to_penitent).to be_present
      end

      context 'with attributes' do
        it 'action is sent' do
          expect(notification_to_penitent.action).to eq('sent')
        end

        it 'unread is true' do
          expect(notification_to_penitent).to be_unread
        end
      end
    end
  end

  context 'after accept' do
    describe 'creates notification to penitent' do
      before do
        subject.save
        subject.update_attribute :status, MeetRequest.statuses[:accepted]
      end

      let (:notification) { subject.notifications.find_by(user_id: penitent.id, action: 'accepted') }

      it 'present' do
        expect(notification).to be_present
      end

      context 'with attributes' do
        it 'unread is true' do
          expect(notification).to be_unread
        end

        it 'has text' do
          result = notification.text

          expect(result).to eq('Votre demande de confession a été acceptée!')
        end
      end
    end
  end

  context 'after refuse' do
    describe 'creates notification to penitent' do
      before do
        subject.save
        subject.update_attribute :status, MeetRequest.statuses[:refused]
      end

      let (:notification) { subject.notifications.find_by(user_id: penitent.id, action: 'refused') }

      it 'present' do
        expect(notification).to be_present
      end

      context 'with attributes' do
        it 'unread is true' do
          expect(notification).to be_unread
        end

        it 'has text' do
          result = notification.text

          expect(result).to eq('Votre demande de confession a été refusée.')
        end
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
