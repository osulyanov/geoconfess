module Askable
  extend ActiveSupport::Concern

  included do
    before_update :remove_old_job
    before_destroy :remove_old_job

  end

  def remove_old_job
    Resque.remove_delayed(AskPriestJob, id)
  end

  module ClassMethods
  end
end
