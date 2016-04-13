class Spot < ActiveRecord::Base
  enum activity_type: [:static, :dynamic]

  belongs_to :priest, class_name: 'User', foreign_key: 'priest_id', inverse_of: 'spots', required: true
  belongs_to :church, dependent: :destroy
  has_many :recurrences, dependent: :destroy

  validates :name, presence: true
  validates :church, presence: true, if: 'static?'
  validates :latitude, presence: true, if: 'dynamic?'
  validates :longitude, presence: true, if: 'dynamic?'

  scope :active, lambda {
    where('spots.priest_id IN (SELECT id FROM users WHERE users.active IS TRUE)')
  }
  scope :now, lambda {
    current_time = Time.zone.now.strftime('%H:%M')
    joins(:recurrences).
      where('recurrences.active_date = ?', Time.zone.today).
      where('recurrences.date = ? OR recurrences.date ISNULL', Time.zone.today).
      where('recurrences.start_at <= time ? AND recurrences.stop_at >= time ?', current_time, current_time).
      distinct.
      select { |s| s.active_today? }
  }
  scope :of_priest, lambda { |priest_id|
    where('spots.priest_id = ? ', priest_id.to_i)
  }
  scope :of_type, lambda { |type|
    where('spots.activity_type = ? ', Spot.activity_types[type.to_s])
  }

  def active_today?
    dynamic? || recurrences.select do |r|
      r.date ==Time.zone.today || r.week_days_arr[Time.zone.today.wday] == 1
    end.any?
  end
end

# == Schema Information
#
# Table name: spots
#
#  id            :integer          not null, primary key
#  name          :string
#  priest_id     :integer
#  church_id     :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  activity_type :integer          default(0), not null
#  latitude      :float
#  longitude     :float
#
# Indexes
#
#  index_spots_on_church_id  (church_id)
#  index_spots_on_priest_id  (priest_id)
#
