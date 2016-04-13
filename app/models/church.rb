class Church < ActiveRecord::Base
  has_many :spots, dependent: :destroy

  validates :name, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true

  after_update :update_spots_coordinates

  def update_spots_coordinates
    return unless latitude_changed? || longitude_changed?
    spots.update_all(latitude: latitude, longitude: longitude)
  end
end

# == Schema Information
#
# Table name: churches
#
#  id         :integer          not null, primary key
#  name       :string
#  latitude   :float
#  longitude  :float
#  street     :string
#  postcode   :string
#  city       :string
#  state      :string
#  country    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
