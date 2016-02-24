FactoryGirl.define do
  factory :church do
    name 'Znamensky Cathedral'
    latitude 55.3585288
    longitude 86.0740275
    street 'Sobornaya 24'
    postcode '650000'
    city 'kemerovo'
    state 'KO'
    country 'Russia'
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
