require 'rails_helper'

describe PushService do

  subject { PushService.new(params) }

  let(:params) { { user: user, text: 'New message' } }
  let(:user) { create(:user) }

  describe '#push' do
    context 'passing valid parameters' do
      context 'os is iOS' do
        let(:user) { create(:user, os: :ios) }

        it 'calls push_ios' do
          allow(subject).to receive(:push_ios)

          subject.push

          expect(subject).to have_received(:push_ios)
        end
      end

      context 'os is Android' do
        let(:user) { create(:user, os: :android) }

        it 'calls push_android' do
          allow(subject).to receive(:push_android)

          subject.push

          expect(subject).to have_received(:push_android)
        end
      end
    end

    context 'text doesn\'t present' do
      let(:params) { { user: user, text: '' } }

      it 'returns false' do
        result = subject.push

        expect(result).to be false
      end
    end

    context 'user doesn\'t have push_token' do
      let(:user) { create(:user, os: :ios, push_token: '') }

      it 'returns false' do
        result = subject.push

        expect(result).to be false
      end
    end
  end

  describe '#push_ios' do
    let(:user) { create(:user, os: :ios) }

    it 'creates APNS notification' do
      app = RailsPushNotifications::APNSApp.first

      expect { subject.push_ios }.to change { app.notifications.all.size }.by(1)
    end
  end
end
