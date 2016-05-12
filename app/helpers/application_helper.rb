module ApplicationHelper
  # Returns an array of abbreviated to two letters week days in French
  # starting from monday.
  def french_weekdays
    %w(Di Lu Ma Me Je Ve Sa)
  end

  # Returns current time in YTC with date 01.01.2000
  #
  #   # If current time is 07:30 (UTC)
  #   time_now # => 2000-01-01 07:30:00 UTC
  def time_now
    ctime = Time.now.getlocal
    Time.new(2000, 01, 01, ctime.strftime('%H'),
             ctime.strftime('%M')).utc
  end
end
