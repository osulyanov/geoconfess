FactoryGirl.define do
  factory :parish do
    sequence :email do |n|
      "parish_#{n}@mysite.com"
    end
    name 'MyParish'
  end
end

# == Schema Information
#
# Table name: parishes
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
