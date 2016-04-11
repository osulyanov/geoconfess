module Askable
  extend ActiveSupport::Concern

  included do
    after_save :remove_old_job
  end

  def remove_old_job
    Resque.remove_delayed(AskPriestJob, id)
  end

  module ClassMethods
  end
end
