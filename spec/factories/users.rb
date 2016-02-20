FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "user_#{n}@mysite.com"
    end
    password '123password%'
  end
end
