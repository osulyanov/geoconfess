require 'rails_helper'

describe PushNotification do
  it 'initializes engine on configuration' do
    engine = double('engine')
    described_class.configure do |config|
      config.engine = engine
    end

    expect(described_class.engine).to eq(engine)
  end

  it 'forwards method calls to engine' do
    engine = double('engine')
    described_class.configure do |config|
      config.engine = engine
    end
    [:push_to_user!, :push_to_channel!].each do |push_method|
      expect(engine).to receive(push_method)

      described_class.send(push_method, uid: 100, payload: {})
    end
  end
end
