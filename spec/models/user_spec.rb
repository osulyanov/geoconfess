require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'not valid without email' do
    subject.email = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without password' do
    subject.password = nil
    expect(subject).not_to be_valid
  end
end
