class Church < ActiveRecord::Base
  has_many :spots, dependent: :destroy

  validates :name, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
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
