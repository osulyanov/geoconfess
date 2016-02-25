FactoryGirl.define do
  factory :spot do
    name 'Spot Name'
    activity_type :static
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
