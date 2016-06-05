require 'rails_helper'

describe 'PushNotification' do
  it 'should initialize engine on configuration' do
    engine = double('engine')
    PushNotification.configure do |config|
      config.engine = engine
    end
    expect(PushNotification.engine).to eq(engine)
  end

  it 'should forward method calls to engine' do
    engine = double('engine')
    PushNotification.configure do |config|
      config.engine = engine
    end
    [:push_to_user!, :push_to_channel!].each do |push_method|
      expect(engine).to receive(push_method)
      PushNotification.send(push_method, uid: 100, payload: {})
    end
  end
end
