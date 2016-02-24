require 'rails_helper'

RSpec.describe MeetRequest, type: :model do
  let (:parish) { create(:parish) }
  let (:priest) { create(:user, role: :priest, parish: parish) }
  let (:penitent) { create(:user, role: :user) }
  subject { build(:meet_request, priest: priest, penitent: penitent) }

  it 'is valid' do
    expect(subject).to be_valid
  end

  it 'not valid without priest' do
    subject.priest = nil
    expect(subject).not_to be_valid
  end

  it 'not valid without penitent' do
    subject.penitent = nil
    expect(subject).not_to be_valid
  end
end
