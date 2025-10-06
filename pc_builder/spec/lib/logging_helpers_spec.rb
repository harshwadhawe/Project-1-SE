require 'rails_helper'

RSpec.describe LoggingHelpers do
  let(:test_class) do
    Class.new do
      include LoggingHelpers
      attr_accessor :id, :name
      
      def initialize(id = nil, name = nil)
        @id = id
        @name = name
      end
      
      def self.name
        'TestClass'
      end
    end
  end
  
  let(:test_instance) { test_class.new(123, 'Test Object') }

  describe 'module inclusion' do
    it 'extends the class with ClassMethods' do
      expect(test_class).to respond_to(:log_class_action)
    end

    it 'includes instance methods' do
      expect(test_instance).to respond_to(:log_action)
      expect(test_instance).to respond_to(:log_error)
      expect(test_instance).to respond_to(:log_performance)
    end
  end

  describe '.log_class_action' do
    it 'logs class-level actions with details' do
      expect(Rails.logger).to receive(:info).with('[TESTCLASS] test_action: {key: "value"}')
      test_class.log_class_action('test_action', key: 'value')
    end

    it 'logs without details' do
      expect(Rails.logger).to receive(:info).with('[TESTCLASS] simple_action: {}')
      test_class.log_class_action('simple_action')
    end
  end

  describe '#log_action' do
    it 'logs instance actions with ID' do
      expect(Rails.logger).to receive(:info).with('[TESTCLASS ID:123] user_login: {user_id: 456}')
      test_instance.log_action('user_login', user_id: 456)
    end

    it 'logs instance actions without ID when ID is nil' do
      instance_without_id = test_class.new(nil)
      expect(Rails.logger).to receive(:info).with('[TESTCLASS] action_name: {data: "test"}')
      instance_without_id.log_action('action_name', data: 'test')
    end
  end

  describe '#log_error' do
    let(:error) { StandardError.new('Test error message') }
    
    before do
      allow(error).to receive(:backtrace).and_return(['line1', 'line2', 'line3', 'line4', 'line5', 'line6'])
    end

    it 'logs error message with context' do
      expect(Rails.logger).to receive(:error).with('[TESTCLASS ID:123] ERROR: Test error message')
      expect(Rails.logger).to receive(:error).with('[TESTCLASS ID:123] CONTEXT: {context: "test"}')
      expect(Rails.logger).to receive(:error).with(include('[TESTCLASS ID:123] BACKTRACE:'))
      
      test_instance.log_error(error, context: 'test')
    end

    it 'logs error without context when context is empty' do
      expect(Rails.logger).to receive(:error).with('[TESTCLASS ID:123] ERROR: Test error message')
      expect(Rails.logger).to receive(:error).with(include('[TESTCLASS ID:123] BACKTRACE:'))
      expect(Rails.logger).not_to receive(:error).with(/CONTEXT/)
      
      test_instance.log_error(error)
    end
  end

  describe '#log_performance' do
    it 'logs debug message for fast operations' do
      allow(Time).to receive(:current).and_return(Time.parse('2025-01-01 00:00:00'), Time.parse('2025-01-01 00:00:00.050'))
      
      expect(Rails.logger).to receive(:debug).with('[TESTCLASS ID:123] PERFORMANCE: fast_operation took 50.0ms')
      
      result = test_instance.log_performance('fast_operation') { 'result' }
      expect(result).to eq('result')
    end

    it 'logs warning for slow operations' do
      allow(Time).to receive(:current).and_return(Time.parse('2025-01-01 00:00:00'), Time.parse('2025-01-01 00:00:00.150'))
      
      expect(Rails.logger).to receive(:warn).with('[TESTCLASS ID:123] SLOW_OPERATION: slow_operation took 150.0ms')
      
      test_instance.log_performance('slow_operation') { 'slow_result' }
    end
  end

  describe '#log_database_query' do
    it 'logs debug message for fast queries' do
      allow(Time).to receive(:current).and_return(Time.parse('2025-01-01 00:00:00'), Time.parse('2025-01-01 00:00:00.100'))
      
      expect(Rails.logger).to receive(:debug).with('[DATABASE] SELECT users - 100.0ms')
      
      result = test_instance.log_database_query('SELECT users') { 'query_result' }
      expect(result).to eq('query_result')
    end

    it 'logs warning for slow queries' do
      allow(Time).to receive(:current).and_return(Time.parse('2025-01-01 00:00:00'), Time.parse('2025-01-01 00:00:00.600'))
      
      expect(Rails.logger).to receive(:debug).with('[DATABASE] SLOW SELECT - 600.0ms')
      expect(Rails.logger).to receive(:warn).with('[SLOW_QUERY] SLOW SELECT took 600.0ms')
      
      test_instance.log_database_query('SLOW SELECT') { 'slow_query_result' }
    end
  end

  describe '#log_user_activity' do
    it 'logs user activity with user ID' do
      expect(Rails.logger).to receive(:info).with('[USER_ACTIVITY] User:456 - login: {ip: "127.0.0.1"}')
      test_instance.log_user_activity(456, 'login', ip: '127.0.0.1')
    end

    it 'logs guest activity' do
      expect(Rails.logger).to receive(:info).with('[USER_ACTIVITY] Guest - page_view: {page: "/home"}')
      test_instance.log_user_activity(nil, 'page_view', page: '/home')
    end
  end

  describe '#log_business_logic' do
    it 'logs business events with data' do
      expect(Rails.logger).to receive(:info).with('[BUSINESS_LOGIC] order_created: {order_id: 123, amount: 99.99}')
      test_instance.log_business_logic('order_created', order_id: 123, amount: 99.99)
    end
  end

  describe '#log_security_event' do
    it 'logs security events with default warning level' do
      expect(Rails.logger).to receive(:warn).with('[SECURITY] unauthorized_access: {ip: "10.0.0.1"}')
      test_instance.log_security_event('unauthorized_access', :warn, ip: '10.0.0.1')
    end

    it 'logs security events with custom severity' do
      expect(Rails.logger).to receive(:error).with('[SECURITY] data_breach: {affected_records: 100}')
      test_instance.log_security_event('data_breach', :error, affected_records: 100)
    end
  end

  describe '#log_api_interaction' do
    it 'logs API interactions with request and response data' do
      expect(Rails.logger).to receive(:info).with('[API] PaymentService - charge_card')
      expect(Rails.logger).to receive(:debug).with('[API_REQUEST] PaymentService: {amount: 100}')
      expect(Rails.logger).to receive(:debug).with('[API_RESPONSE] PaymentService: {transaction_id: "12345"}')
      
      test_instance.log_api_interaction('PaymentService', 'charge_card', { amount: 100 }, { transaction_id: '12345' })
    end

    it 'logs API interactions without request/response data when empty' do
      expect(Rails.logger).to receive(:info).with('[API] UserService - get_profile')
      expect(Rails.logger).not_to receive(:debug)
      
      test_instance.log_api_interaction('UserService', 'get_profile')
    end
  end
end

RSpec.describe MemoryLogger do
  describe '.log_memory_usage' do
    before do
      allow(GC).to receive(:stat).and_return({
        heap_live_slots: 50000,
        count: 10
      })
      allow(MemoryLogger).to receive(:`).with(/ps -o pid,vsz,rss/).and_return("PID VSZ RSS\n1234 100000 25000")
    end

    it 'logs memory usage with context' do
      expect(Rails.logger).to receive(:info).with('[MEMORY TEST] Objects: 50000, GC Count: 10, Memory: 25000KB RSS')
      MemoryLogger.log_memory_usage('TEST')
    end

    it 'logs memory usage without context' do
      expect(Rails.logger).to receive(:info).with('[MEMORY] Objects: 50000, GC Count: 10, Memory: 25000KB RSS')
      MemoryLogger.log_memory_usage('')
    end

    context 'when ps command fails' do
      before do
        allow(MemoryLogger).to receive(:`).and_return("")
      end

      it 'logs memory usage with unknown memory' do
        expect(Rails.logger).to receive(:info).with('[MEMORY] Objects: 50000, GC Count: 10, Memory: unknown')
        MemoryLogger.log_memory_usage
      end
    end
  end
end

RSpec.describe PerformanceMonitor do
  describe '.monitor_action' do
    before do
      allow(MemoryLogger).to receive(:log_memory_usage).and_return(nil)
      allow(Time).to receive(:current).and_return(Time.parse('2025-01-01 00:00:00'), Time.parse('2025-01-01 00:00:00.300'))
    end

    it 'monitors action performance' do
      expect(MemoryLogger).to receive(:log_memory_usage).with('START TestController#index')
      expect(MemoryLogger).to receive(:log_memory_usage).with('END TestController#index')
      expect(Rails.logger).to receive(:info).with('[PERFORMANCE] TestController#index completed in 300.0ms')
      
      result = PerformanceMonitor.monitor_action('TestController', 'index') { 'action_result' }
      expect(result).to eq('action_result')
    end

    it 'logs warning for slow actions' do
      allow(Time).to receive(:current).and_return(Time.parse('2025-01-01 00:00:00'), Time.parse('2025-01-01 00:00:00.600'))
      
      expect(Rails.logger).to receive(:info).with('[PERFORMANCE] SlowController#show completed in 600.0ms')
      expect(Rails.logger).to receive(:warn).with('[SLOW_ACTION] SlowController#show took 600.0ms')
      
      PerformanceMonitor.monitor_action('SlowController', 'show') { 'slow_result' }
    end
  end
end