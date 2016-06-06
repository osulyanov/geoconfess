module PushNotification
  mattr_accessor :engine

  class << self
    extend Forwardable
    def_delegators :engine, :push_to_user!, :push_to_channel!
  end

  def self.configure
    yield self
  end
end
