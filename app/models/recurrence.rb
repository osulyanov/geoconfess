class Recurrence < ActiveRecord::Base
  include ApplicationHelper
  include Askable

  belongs_to :spot, required: true

  scope :in_the_future, -> { where('recurrences.date >= ? OR recurrences.date ISNULL', Time.zone.today) }

  validates :start_at, presence: true
  validates :stop_at, presence: true
  validates :date, presence: true, if: 'week_days.blank?'
  validates :days, presence: true, if: 'date.blank?'

  def week_days_arr
    w = read_attribute(:days)
    return [] if w.blank? || w == 0

    # first you have to convert the integer to a binary array
    days_as_binary = Math.log2(w).floor.downto(0).map { |nth_bit| w[nth_bit] }

    # alternatively
    # days_as_binary = read_attribute(:week_days).to_s(2).split('').map(&:to_i)

    # make sure it has an element for every day of the week
    [0] * (7 - days_as_binary.size) + days_as_binary
  end

  def week_days
    week_days_from_array(Date::DAYNAMES)
  end

  def week_days_fr
    week_days_from_array(french_weekdays)
  end

  def week_days_from_array(weekdays_array)
    padded_binary = week_days_arr
    # map the binary array to day names
    padded_binary.each_with_index.map do |d, idx|
      weekdays_array[idx] if d == 1
    end.compact
  end

  def week_days=(values)
    days = Date::DAYNAMES.map { |d| values.include?(d) ? 1 : 0 }
    write_attribute(:days, days.join.to_i(2))
  end

  def today?
    ctime = Time.now
    time_now = Time.new(2000, 01, 01, ctime.strftime('%H'), ctime.strftime('%M')).utc
    today = Time.zone.today
    ((date.present? && date == today) ||
      (week_days.include? today.strftime('%A'))
    ) && start_at > time_now
  end

  def start_today_at
    today = Time.zone.today
    Time.new(today.strftime('%Y'), today.strftime('%m'), today.strftime('%d'),
             start_at.strftime('%H'), start_at.strftime('%M'))
  end
end

# == Schema Information
#
# Table name: recurrences
#
#  id          :integer          not null, primary key
#  spot_id     :integer
#  date        :date
#  start_at    :time
#  stop_at     :time
#  days        :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  active_date :date
#  busy_count  :integer          default(0), not null
#
# Indexes
#
#  index_recurrences_on_spot_id  (spot_id)
#
