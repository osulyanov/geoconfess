module Askable
  extend ActiveSupport::Concern

  included do
    before_update :remove_old_job
    before_destroy :remove_old_job
    after_update :create_job
    after_create :create_job
  end

  def remove_old_job
    Rails.logger.info "remove_old_job #{id}"
    Resque.remove_delayed(AskPriestJob, id)
  end

  def create_job
    Rails.logger.info "create_job #{id}"
    return unless today?
    Rails.logger.info "start job at #{start_today_at - 1.hour}"
    Resque.enqueue_at(start_today_at - 1.hour, AskPriestJob, id)
  end

  module ClassMethods
  end
end
