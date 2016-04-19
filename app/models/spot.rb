class Spot < ActiveRecord::Base
  reverse_geocoded_by :latitude, :longitude

  enum activity_type: [:static, :dynamic]

  belongs_to :priest, class_name: 'User', foreign_key: 'priest_id',
             inverse_of: 'spots', required: true
  has_many :recurrences, dependent: :destroy

  validates :name, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true

  scope :active, lambda {
    where('spots.priest_id IN (SELECT id FROM users WHERE users.active IS TRUE)')
  }
  scope :now, lambda {
    where('(spots.activity_type = ? AND spots.updated_at > NOW() - \'15 minutes\'::INTERVAL) OR spots.id IN (?)', activity_types[:dynamic],
          Recurrence.now.map { |r| r[:spot_id] })
  }
  scope :of_priest, lambda { |priest_id|
    where('spots.priest_id = ? ', priest_id.to_i)
  }
  scope :of_type, lambda { |type|
    where('spots.activity_type = ? ', activity_types[type.to_s])
  }
  scope :nearest, lambda { |lat, lng, distance|
    near([lat, lng], distance, order: 'distance', units: :km)
  }
  scope :outdated, lambda {
    where('spots.activity_type = ?', activity_types[:dynamic]).
      where('spots.updated_at < NOW() - \'15 minutes\'::INTERVAL')
  }

  def self.assign_or_new(params)
    dynamic_id = activity_types[:dynamic]
    if params[:activity_type] == 'dynamic'
      spot = find_by(activity_type: dynamic_id)
      spot.assign_attributes params if spot
    end
    spot ||= new(params)
  end

  def active_today?
    dynamic? || recurrences.select do |r|
      r.date == Time.zone.today || r.week_days_arr[Time.zone.today.wday] == 1
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
#  street        :string
#  postcode      :string
#  city          :string
#  state         :string
#  country       :string
#
# Indexes
#
#  index_spots_on_church_id  (church_id)
#  index_spots_on_priest_id  (priest_id)
#
