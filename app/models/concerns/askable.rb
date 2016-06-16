module Askable
  extend ActiveSupport::Concern

  included do
    before_destroy :remove_old_job
    after_update :update_job, if: 'dates_changed?'
    after_create :create_job
  end

  def remove_old_job
    Rails.logger.info "remove_old_job #{id}"
    Resque.remove_delayed(AskPriestJob, id)
  end

  def create_job
    Rails.logger.info "create_job #{id}"
    return unless today?
    one_hour_ago = start_today_at - 1.hour
    Rails.logger.info "start job at #{one_hour_ago}"
    AskPriestJob.set(wait_until: one_hour_ago).perform_later(id)
  end

  def update_job
    remove_old_job
    create_job
  end

  def confirm_availability
    assign_attributes busy_count: 0, active_date: Time.zone.today
  end

  def confirm_availability!
    confirm_availability
    save
  end

  def dates_changed?
    date_changed? || start_at_changed? || stop_at_changed? || days_changed?
  end

  module ClassMethods
  end
end
