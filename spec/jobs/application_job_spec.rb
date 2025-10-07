require 'rails_helper'

RSpec.describe ApplicationJob, type: :job do
  describe 'base job configuration' do
    it 'inherits from ActiveJob::Base' do
      expect(ApplicationJob.superclass).to eq(ActiveJob::Base)
    end

    it 'has access to ActiveJob methods' do
      expect(ApplicationJob).to respond_to(:perform_later)
      expect(ApplicationJob).to respond_to(:perform_now)
      expect(ApplicationJob).to respond_to(:queue_as)
    end

    it 'can create job instances' do
      job = ApplicationJob.new
      expect(job).to be_an_instance_of(ApplicationJob)
      expect(job).to be_kind_of(ActiveJob::Base)
    end
  end

  describe 'job inheritance' do
    # Test that custom jobs can inherit from ApplicationJob
    let(:test_job_class) do
      Class.new(ApplicationJob) do
        queue_as :test_queue

        def perform(message)
          Rails.logger.info "Test job executed with message: #{message}"
          message.upcase
        end
      end
    end

    it 'allows inheritance for custom jobs' do
      expect(test_job_class.superclass).to eq(ApplicationJob)
    end

    it 'can set custom queue names' do
      expect(test_job_class.queue_name).to eq('test_queue')
    end

    it 'can perform jobs synchronously' do
      result = test_job_class.perform_now('hello world')
      expect(result).to eq('HELLO WORLD')
    end

    it 'can enqueue jobs for later execution' do
      expect {
        test_job_class.perform_later('test message')
      }.to have_enqueued_job(test_job_class).with('test message')
    end
  end

  describe 'error handling configuration' do
    it 'has commented retry configuration available' do
      # Check that the ApplicationJob class has the retry configuration commented out
      file_content = File.read(Rails.root.join('app', 'jobs', 'application_job.rb'))
      expect(file_content).to include('# retry_on ActiveRecord::Deadlocked')
      expect(file_content).to include('# discard_on ActiveJob::DeserializationError')
    end

    it 'can be configured with retry policies' do
      test_job_with_retry = Class.new(ApplicationJob) do
        retry_on StandardError, wait: 1.second, attempts: 3

        def perform
          raise StandardError, 'Test error'
        end
      end

      # Check that the retry policy was configured
      expect(test_job_with_retry.rescue_handlers).not_to be_empty
    end

    it 'can be configured with discard policies' do
      test_job_with_discard = Class.new(ApplicationJob) do
        discard_on ArgumentError

        def perform
          raise ArgumentError, 'Test discard'
        end
      end

      # Check that the discard policy was configured
      expect(test_job_with_discard.rescue_handlers).not_to be_empty
    end
  end

  describe 'ActiveJob integration' do
    it 'supports job callbacks' do
      callback_job = Class.new(ApplicationJob) do
        before_perform :log_start
        after_perform :log_finish

        def perform
          'job executed'
        end

        private

        def log_start
          Rails.logger.info 'Job starting'
        end

        def log_finish
          Rails.logger.info 'Job finished'
        end
      end

      expect(callback_job._perform_callbacks).not_to be_empty
    end

    it 'supports job serialization' do
      simple_job = Class.new(ApplicationJob) do
        def perform(data)
          data
        end
      end

      job_data = { 'test' => 'value' }
      job = simple_job.new(job_data)
      
      # Test that job can be serialized
      expect(job.serialize).to include('job_class' => simple_job.name)
    end
  end
end