class CleanupOutdatedMessagesService
  def initialize
    @outdated_messages = messages_to_remove
  end

  # Destroys all +outdated_messages+.
  def perform
    @outdated_messages.destroy_all
  end

  # Returns a collection of outdated messages (<tt>Message.outdated</tt>) to
  # remove them.
  def messages_to_remove
    Message.outdated
  end
end
