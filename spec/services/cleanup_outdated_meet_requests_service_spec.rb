require 'rails_helper'

describe CleanupOutdatedMeetRequestsService do

  let(:priest) { create(:user, role: :priest) }
  let (:penitent) { create(:user, role: :user) }
  let!(:request_25_h_ago) do
    create(:meet_request, priest: priest, penitent: penitent,
           created_at: 25.hours.ago)
  end
  let!(:request_23_h_ago) do
    create(:meet_request, priest: priest, penitent: penitent,
           created_at: 23.hours.ago)
  end

  subject { described_class.new }

  describe '#meet_requests_to_remove' do
    it 'returns outdated meet requests' do
      result = subject.meet_requests_to_remove

      expect(result).to include(request_25_h_ago)
    end

    it 'doesn\'t return actual spots' do
      result = subject.meet_requests_to_remove

      expect(result).not_to include(request_23_h_ago)
    end
  end

  describe '#perform' do
    it 'removes outdated meet requests' do
      subject.perform

      result = MeetRequest.all

      expect(result).not_to include(request_25_h_ago)
    end

    it 'doesn\'t remove actual meet requests' do
      subject.perform

      result = MeetRequest.all

      expect(result).to include(request_23_h_ago)
    end
  end
end
