class Recurrence < ActiveRecord::Base
  include ApplicationHelper
  include Askable

  belongs_to :spot, required: true

  scope :in_the_future, lambda {
    where('recurrences.date >= ? OR recurrences.date ISNULL', Time.zone.today)
  }
  scope :confirmed_availability, -> { where active_date: Time.zone.today }
  scope :now, lambda {
    current_time = Time.zone.now.strftime('%H:%M')
    where('recurrences.active_date = ?', Time.zone.today)
      .where('recurrences.date = ? OR recurrences.date ISNULL', Time.zone.today)
      .where('recurrences.start_at <= time ? AND recurrences.stop_at >= time ?',
             current_time, current_time)
      .select(&:active_this_wday?)
  }

  validates :start_at, presence: true
  validates :stop_at, presence: true
  validates :date, presence: true, if: 'week_days.blank?'
  validates :days, presence: true, if: 'date.blank?'

  before_create :set_active_date, if: 'active_date.blank?'

  def set_active_date
    self.active_date = Time.zone.today
  end

  def week_days_arr
    w = self[:days]
    return [] if w.blank? || w == 0
    days_as_binary = Math.log2(w).floor.downto(0).map { |nth_bit| w[nth_bit] }
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
    self[:days] = days.join.to_i(2)
  end

  # true if recurrence is active by this week days
  def active_this_wday?
    return true if date.present?
    today = Time.zone.today
    week_days.include? today.strftime('%A')
  end

  # true if recurrence will start today
  def today?
    today = Time.zone.today
    ((date.present? && date == today) ||
      (week_days.include? today.strftime('%A'))
    ) && start_at > time_now
  end

  # DateTime when recurrence starts today
  def start_today_at
    today = Time.zone.today
    Time.zone.local(today.strftime('%Y'), today.strftime('%m'),
                    today.strftime('%d'), start_at.strftime('%H'),
                    start_at.strftime('%M'))
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
