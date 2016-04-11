module Askable
  extend ActiveSupport::Concern

  included do
    after_update :remove_old_job
    after_destroy :remove_old_job
  end

  def remove_old_job
    Resque.remove_delayed(AskPriestJob, id)
  end

  module ClassMethods
  end
end
