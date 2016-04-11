module Askable
  extend ActiveSupport::Concern

  included do
    before_update :remove_old_job
    before_destroy :remove_old_job
    after_create :create_job
  end

  def remove_old_job
    Resque.remove_delayed(AskPriestJob, id)
  end

  def create_job
    return unless
    Resque.enqueue_at(5.seconds.from_now, AskPriestJob, id)
  end

  module ClassMethods
  end
end
