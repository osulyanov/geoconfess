FactoryGirl.define do
  factory :access_token, class: 'Doorkeeper::AccessToken' do
    resource_owner_id nil
    expires_in 3600
  end
end
