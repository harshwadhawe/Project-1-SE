# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationMailer, type: :mailer do
  describe 'default configuration' do
    it 'sets the default from address' do
      expect(ApplicationMailer.default[:from]).to eq('from@example.com')
    end

    it 'uses the mailer layout' do
      # ApplicationMailer sets layout "mailer" in the class definition
      expect(ApplicationMailer._layout).to eq('mailer')
    end

    it 'inherits from ActionMailer::Base' do
      expect(ApplicationMailer.superclass).to eq(ActionMailer::Base)
    end
  end

  describe 'mailer inheritance' do
    # Test that custom mailers can inherit from ApplicationMailer
    let(:test_mailer_class) do
      Class.new(ApplicationMailer) do
        def test_email
          mail(to: 'test@example.com', subject: 'Test Email') do |format|
            format.text { render plain: 'Test email body' }
          end
        end
      end
    end

    it 'allows inheritance for custom mailers' do
      expect(test_mailer_class.superclass).to eq(ApplicationMailer)
    end

    it 'inherits default from address' do
      mailer = test_mailer_class.new
      email = mailer.test_email
      expect(email.from).to include('from@example.com')
    end

    it 'can send test emails' do
      mailer = test_mailer_class.new
      email = mailer.test_email
      expect(email.to).to include('test@example.com')
      expect(email.subject).to eq('Test Email')
    end
  end

  describe 'ActionMailer configuration' do
    it 'has access to ActionMailer methods' do
      expect(ApplicationMailer).to respond_to(:default)
      expect(ApplicationMailer.new).to respond_to(:mail)
      expect(ApplicationMailer).to respond_to(:layout)
    end

    it 'can create mailer instances' do
      mailer = ApplicationMailer.new
      expect(mailer).to be_an_instance_of(ApplicationMailer)
      expect(mailer).to be_kind_of(ActionMailer::Base)
    end
  end
end
