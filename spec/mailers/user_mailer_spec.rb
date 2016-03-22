require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  subject { create :user }

  it 'sends an email' do
    expect { subject.send_welcome_message }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
