FactoryGirl.define do
  factory :favorite do
    user { create(:user) }
    priest { create(:user, role: :priest) }
  end
end
