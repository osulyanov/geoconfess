require 'rails_helper'

describe PushService do

  subject { PushService.new(params) }

  let(:params) { { user: user, text: 'New message' } }
  let(:user) { create(:user) }

  describe '#push' do
    context 'passing valid parameters' do
      context 'os is iOS' do
        xit 'calls push_ios' do
          result = subject.push

          expect(result).to receive(:push_ios)
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
end
