require 'rails_helper'

describe 'PushNotification::Engine::FCM' do
  before(:each) do
    @payload = {
      badge: 1,
      body: 'test message',
      sound: 'default',
      data: {
        event: :test_event,
        foo: :bar
      }
    }
  end

  describe ':push_to_user!' do
    describe 'errors' do
      it 'should return 401 status if server_key is invalid' do
        subject = PushNotification::Engine::FCM.new(server_key: 'invalid_key')
        VCR.use_cassette("FCM", record: :none, match_requests_on: [:host, :path, :headers, :body]) do
          response = subject.push_to_user!(uid: 100, payload: @payload)
          expect(response[:status_code]).to eq(401)
        end
      end
    end

    describe 'success' do
      it 'should return 200 status' do
        subject = PushNotification::Engine::FCM.new(server_key: Rails.application.secrets.fcm_server_key)
        VCR.use_cassette("FCM", record: :none, match_requests_on: [:host, :path, :headers, :body]) do
          response = subject.push_to_user!(uid: 100, payload: @payload)
          expect(response[:status_code]).to eq(200)
        end
      end
    end
  end

  describe ':push_to_channel!' do
    describe 'errors' do
      it 'should return 401 status if server_key is invalid' do
        subject = PushNotification::Engine::FCM.new(server_key: 'invalid_key')
        VCR.use_cassette("FCM", record: :none, match_requests_on: [:host, :path, :headers, :body]) do
          response = subject.push_to_channel!(uid: 100, payload: @payload)
          expect(response[:status_code]).to eq(401)
        end
      end
    end

    describe 'success' do
      it 'should return 200 status' do
        subject = PushNotification::Engine::FCM.new(server_key: Rails.application.secrets.fcm_server_key)
        VCR.use_cassette("FCM", record: :none, match_requests_on: [:host, :path, :headers, :body]) do
          response = subject.push_to_channel!(uid: 100, payload: @payload)
          expect(response[:status_code]).to eq(200)
        end
      end
    end
  end
end
