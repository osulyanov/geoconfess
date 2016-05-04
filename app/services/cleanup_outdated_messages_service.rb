class CleanupOutdatedMessagesService
  def initialize
    @outdated_messages = messages_to_remove
  end

  def perform
    @outdated_messages.destroy_all
  end

  def messages_to_remove
    Message.outdated
  end
end
