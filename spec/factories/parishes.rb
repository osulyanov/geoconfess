FactoryGirl.define do
  factory :parish do
    name 'MyParish'
  end
end

# == Schema Information
#
# Table name: parishes
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
