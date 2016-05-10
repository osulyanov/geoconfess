module ApplicationHelper
  def french_weekdays
    %w(Di Lu Ma Me Je Ve Sa)
  end

  def time_now
    ctime = Time.now.getlocal
    Time.new(2000, 01, 01, ctime.strftime('%H'),
             ctime.strftime('%M')).utc
  end
end
