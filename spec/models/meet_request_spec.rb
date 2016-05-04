require 'rails_helper'

describe MeetRequest, type: :model do
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

      result = described_class.active

      expect(result).to include(request_23_h_ago)
    end

    it 'doesn\'t return requests created more than 1 day ago' do
      request_25_h_ago = create(:meet_request, priest: priest, penitent: penitent, created_at: 25.hours.ago)

      result = described_class.active

      expect(result).not_to include(request_25_h_ago)
    end
  end

  describe '.outdated' do
    it 'returns requests older than 1 day' do
      request_25_h_ago = create(:meet_request, priest: priest, penitent: penitent, created_at: 25.hours.ago)

      result = described_class.outdated

      expect(result).to include(request_25_h_ago)
    end

    it 'doesn\'t return requests created less than 1 day ago' do
      request_23_h_ago = create(:meet_request, priest: priest, penitent: penitent, created_at: 23.hours.ago)

      result = described_class.outdated

      expect(result).not_to include(request_23_h_ago)
    end
  end

  describe '.for_user' do
    let (:priest) { create(:user, role: :priest) }
    let (:penitent) { create(:user, role: :user) }
    let (:other_user) { create(:user, role: :user) }
    let! (:meet_request) { create(:meet_request, priest: priest, penitent: penitent) }

    it 'returns requests to user' do
      result = described_class.for_user(priest.id)

      expect(result).to include(meet_request)
    end

    it 'returns requests from user' do
      result = described_class.for_user(penitent.id)

      expect(result).to include(meet_request)
    end

    it 'doesn\'t return requests of other user' do
      result = described_class.for_user(other_user.id)

      expect(result).not_to include(meet_request)
    end
  end

  describe '.assign_or_new' do
    let (:priest) { create(:user, role: :priest) }
    let (:penitent) { create(:user, role: :user) }
    let (:other_user) { create(:user, role: :user) }
    let! (:other_meet_request) do
      create(:meet_request, priest_id: priest.id,
                            penitent_id: other_user.id)
    end
    let (:meet_request_attrs) do
      attributes_for(:meet_request, priest_id: priest.id, latitude: 11.2,
                                    longitude: 22.2)
    end

    context 'request doesn\'t exist' do
      subject { penitent.outbound_requests.assign_or_new(meet_request_attrs) }

      it 'initialize a new one' do
        expect(subject).to be_a_new(described_class)
      end

      it 'with priest' do
        expect(subject.priest_id).to eq(priest.id)
      end

      it 'with penitent' do
        expect(subject.penitent_id).to eq(penitent.id)
      end
    end

    context 'request already exists' do
      let! (:meet_request) do
        create(:meet_request, priest: priest, penitent: penitent,
                              latitude: 11.1, longitude: 22.1)
      end
      subject { penitent.outbound_requests.assign_or_new(meet_request_attrs) }

      it 'return existing request' do
        expect(subject.id).to be(meet_request.id)
      end

      it 'with priest' do
        expect(subject.priest_id).to eq(priest.id)
      end

      it 'with penitent' do
        expect(subject.penitent_id).to eq(penitent.id)
      end

      it 'with new coordinates' do
        expect(subject.latitude).to eq(meet_request_attrs[:latitude])
        expect(subject.longitude).to eq(meet_request_attrs[:longitude])
      end
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
        subject.update_attribute :status, described_class.statuses[:accepted]
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
        subject.update_attribute :status, described_class.statuses[:refused]
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
