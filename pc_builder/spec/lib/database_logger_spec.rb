require 'rails_helper'
require 'ostruct'

RSpec.describe DatabaseLogger do
  describe 'module structure' do
    it 'defines class methods module' do
      expect(DatabaseLogger.const_defined?(:ClassMethods)).to be true
    end

    it 'can be included in classes' do
      test_class = Class.new do
        # Stub ActiveRecord callback methods
        def self.after_initialize(*args); end
        def self.before_save(*args); end
        def self.after_save(*args); end
        def self.before_destroy(*args); end
        def self.after_destroy(*args); end
        
        include DatabaseLogger
      end
      
      expect(test_class).to respond_to(:log_query)
      expect(test_class).to respond_to(:with_query_logging)
    end
  end

  describe 'ClassMethods' do
    let(:test_class) do
      Class.new do
        extend DatabaseLogger::ClassMethods
        def self.name; 'TestModel'; end
      end
    end

    describe '.log_query' do
      it 'logs database queries with conditions' do
        expect(Rails.logger).to receive(:debug).with('[TESTMODEL_QUERY] SELECT: {where: {active: true}}')
        test_class.log_query('SELECT', where: { active: true })
      end

      it 'logs queries without conditions' do
        expect(Rails.logger).to receive(:debug).with('[TESTMODEL_QUERY] COUNT: {}')
        test_class.log_query('COUNT')
      end
    end

    describe '.with_query_logging' do
      it 'logs query execution with timing for fast queries' do
        allow(Time).to receive(:current).and_return(Time.parse('2025-01-01 00:00:00'), Time.parse('2025-01-01 00:00:00.050'))
        
        result_array = [1, 2, 3]
        allow(result_array).to receive(:count).and_return(3)
        
        expect(Rails.logger).to receive(:debug).with('[TESTMODEL_QUERY] Starting: find active users')
        expect(Rails.logger).to receive(:debug).with('[TESTMODEL_QUERY] Completed: find active users - 3 records in 50.0ms')
        
        result = test_class.with_query_logging('find active users') { result_array }
        expect(result).to eq(result_array)
      end

      it 'logs warning for slow queries' do
        allow(Time).to receive(:current).and_return(Time.parse('2025-01-01 00:00:00'), Time.parse('2025-01-01 00:00:00.150'))
        
        result = 'single_result'
        
        expect(Rails.logger).to receive(:debug).with('[TESTMODEL_QUERY] Starting: complex join query')
        expect(Rails.logger).to receive(:debug).with('[TESTMODEL_QUERY] Completed: complex join query - 1 records in 150.0ms')
        expect(Rails.logger).to receive(:warn).with('[TESTMODEL_SLOW_QUERY] complex join query took 150.0ms')
        
        test_class.with_query_logging('complex join query') { result }
      end

      it 'handles array results' do
        allow(Time).to receive(:current).and_return(Time.parse('2025-01-01 00:00:00'), Time.parse('2025-01-01 00:00:00.030'))
        
        result_array = %w[a b c d]
        
        expect(Rails.logger).to receive(:debug).with('[TESTMODEL_QUERY] Starting: array query')
        expect(Rails.logger).to receive(:debug).with('[TESTMODEL_QUERY] Completed: array query - 4 records in 30.0ms')
        
        test_class.with_query_logging('array query') { result_array }
      end
    end
  end

  describe '#log_model_summary' do
    let(:test_instance) do
      OpenStruct.new.tap do |obj|
        obj.extend(DatabaseLogger)
        def obj.class; TestModel; end
      end
    end

    before do
      stub_const('TestModel', Class.new)
    end

    context 'for User model' do
      before do
        test_instance.define_singleton_method(:class) { User }
        test_instance.name = 'John Doe'
        test_instance.email = 'john@example.com'
      end
      
      it 'returns user summary' do
        summary = test_instance.send(:log_model_summary)
        expect(summary).to eq('John Doe (john@example.com)')
      end
    end

    context 'for Build model' do
      before do
        test_instance.define_singleton_method(:class) { Build }
        test_instance.name = 'Gaming PC'
        test_instance.user_id = 456
      end
      
      it 'returns build summary' do
        summary = test_instance.send(:log_model_summary)
        expect(summary).to eq('Gaming PC by User:456')
      end
    end

    context 'for Part models' do
      %w[Part Cpu Gpu Motherboard Memory Storage Cooler PcCase Psu].each do |part_type|
        it "returns #{part_type} summary" do
          part_class = Class.new
          stub_const(part_type, part_class)
          
          test_instance.define_singleton_method(:class) { part_class }
          test_instance.brand = 'ASUS'
          test_instance.name = 'RTX 4080'
          test_instance.price_in_dollars = 899.99
          
          summary = test_instance.send(:log_model_summary)
          expect(summary).to eq('ASUS RTX 4080 - $899.99')
        end

        it "handles #{part_type} without price" do
          part_class = Class.new
          stub_const(part_type, part_class)
          
          test_instance.define_singleton_method(:class) { part_class }
          test_instance.brand = 'Intel'
          test_instance.name = 'i7-13700K'
          test_instance.define_singleton_method(:price_in_dollars) { raise NoMethodError }
          
          summary = test_instance.send(:log_model_summary)
          expect(summary).to eq('Intel i7-13700K - $N/A')
        end
      end
    end

    context 'for BuildItem model' do
      before do
        test_instance.define_singleton_method(:class) { BuildItem }
        test_instance.quantity = 2
        test_instance.build_id = 789
      end
      
      it 'returns build item summary' do
        mock_part = double('Part', name: 'RTX 4080')
        test_instance.part = mock_part
        
        summary = test_instance.send(:log_model_summary)
        expect(summary).to eq('RTX 4080 x2 in Build:789')
      end

      it 'handles build item with nil part' do
        test_instance.part = nil
        
        summary = test_instance.send(:log_model_summary)
        expect(summary).to eq(' x2 in Build:789')
      end
    end

    context 'for other models' do
      it 'returns generic ID summary for other models' do
        other_class = Class.new
        stub_const('SomeOtherModel', other_class)
        
        test_instance.define_singleton_method(:class) { other_class }
        test_instance.id = 999
        
        summary = test_instance.send(:log_model_summary)
        expect(summary).to eq('ID:999')
      end

      it 'handles new records without ID' do
        other_class = Class.new
        stub_const('SomeOtherModel', other_class)
        
        test_instance.define_singleton_method(:class) { other_class }
        test_instance.define_singleton_method(:id) { raise NoMethodError }
        
        summary = test_instance.send(:log_model_summary)
        expect(summary).to eq('ID:new')
      end
    end
  end

  describe 'instance methods (callback logging)' do
    let(:test_model) do
      Class.new do
        # Mock ActiveRecord callback methods
        def self.after_initialize(*args); end
        def self.before_save(*args); end
        def self.after_save(*args); end
        def self.before_destroy(*args); end
        def self.after_destroy(*args); end
        
        include ActiveModel::Model
        include ActiveModel::Attributes
        include ActiveModel::Dirty
        include DatabaseLogger
        
        attr_accessor :id, :name, :email, :created_at, :updated_at
        attr_accessor :new_record, :persisted, :previously_new_record
        
        def self.name; 'TestModel'; end
        
        def new_record?; @new_record || false; end
        def persisted?; @persisted || false; end
        def previously_new_record?; @previously_new_record || false; end
        
        def changed_attributes; @changed_attributes ||= {}; end
        def mark_changed(attr); @changed_attributes ||= {}; @changed_attributes[attr] = 'old_value'; end
      end
    end
    
    let(:test_instance) { test_model.new }

    describe '#log_model_initialization' do
      it 'logs model initialization for persisted records' do
        test_instance.id = 123
        test_instance.name = 'Test Record'
        test_instance.instance_variable_set(:@persisted, true)
        
        expect(Rails.logger).to receive(:debug).with('[TESTMODEL] Initialized: ID:123')
        test_instance.send(:log_model_initialization)
      end
    end

    describe '#log_model_save_attempt' do
      it 'logs creation attempt for new records' do
        test_instance.instance_variable_set(:@new_record, true)
        test_instance.name = 'New Record'
        # For new records, id is not set yet, so it shows as blank in the summary
        
        expect(Rails.logger).to receive(:info).with('[TESTMODEL] Creating: ID:')
        test_instance.send(:log_model_save_attempt)
      end

      it 'logs update attempt for existing records' do
        test_instance.id = 456
        test_instance.instance_variable_set(:@new_record, false)
        test_instance.mark_changed('name')
        test_instance.mark_changed('email')
        
        expect(Rails.logger).to receive(:info).with('[TESTMODEL] Updating ID:456 - Changed: name, email')
        test_instance.send(:log_model_save_attempt)
      end
    end

    describe '#log_model_saved' do
      it 'logs successful creation for previously new records' do
        test_instance.id = 789
        test_instance.name = 'Created Record'
        test_instance.instance_variable_set(:@previously_new_record, true)
        
        expect(Rails.logger).to receive(:info).with('[TESTMODEL] Created: ID:789 - ID:789')
        test_instance.send(:log_model_saved)
      end

      it 'logs successful update for existing records' do
        test_instance.id = 101
        test_instance.instance_variable_set(:@previously_new_record, false)
        
        expect(Rails.logger).to receive(:info).with('[TESTMODEL] Updated: ID:101')
        test_instance.send(:log_model_saved)
      end
    end

    describe '#log_model_destroy_attempt' do
      it 'logs destruction attempt' do
        test_instance.id = 202
        test_instance.name = 'To Be Destroyed'
        
        expect(Rails.logger).to receive(:warn).with('[TESTMODEL] Destroying: ID:202 - ID:202')
        test_instance.send(:log_model_destroy_attempt)
      end
    end

    describe '#log_model_destroyed' do
      it 'logs successful destruction' do
        test_instance.id = 303
        
        expect(Rails.logger).to receive(:warn).with('[TESTMODEL] Destroyed: ID:303')
        test_instance.send(:log_model_destroyed)
      end
    end
  end

  describe 'integration with ActiveRecord callbacks' do
    let(:user_class) do
      Class.new do
        # Mock ActiveRecord callback methods
        def self.after_initialize(*args); end
        def self.before_save(*args); end
        def self.after_save(*args); end
        def self.before_destroy(*args); end
        def self.after_destroy(*args); end
        
        include ActiveModel::Model
        include ActiveModel::Attributes
        include DatabaseLogger
        
        attr_accessor :id, :name, :email
        
        def self.name; 'User'; end
        def persisted?; true; end
        def new_record?; false; end
        def previously_new_record?; false; end
        def changed_attributes; {}; end
      end
    end

    it 'includes callback methods when module is included' do
      test_class = Class.new do
        # Mock ActiveRecord callback methods
        def self.after_initialize(*args); end
        def self.before_save(*args); end
        def self.after_save(*args); end
        def self.before_destroy(*args); end
        def self.after_destroy(*args); end
        
        include DatabaseLogger
      end

      instance = test_class.new
      # These methods are private, so we need to check with include_private: true
      expect(instance.private_methods).to include(:log_model_initialization)
      expect(instance.private_methods).to include(:log_model_save_attempt)
      expect(instance.private_methods).to include(:log_model_saved)
      expect(instance.private_methods).to include(:log_model_destroy_attempt)
      expect(instance.private_methods).to include(:log_model_destroyed)
    end

    it 'logs user-specific summary in callbacks' do
      user = user_class.new
      user.id = 999
      user.name = 'John Doe'
      user.email = 'john@example.com'
      
      expect(Rails.logger).to receive(:debug).with('[USER] Initialized: John Doe (john@example.com)')
      user.send(:log_model_initialization)
    end
  end

  describe 'edge cases and error handling' do
    let(:test_model) do
      Class.new do
        # Mock ActiveRecord callback methods
        def self.after_initialize(*args); end
        def self.before_save(*args); end
        def self.after_save(*args); end
        def self.before_destroy(*args); end
        def self.after_destroy(*args); end
        
        include ActiveModel::Model
        include DatabaseLogger
        
        attr_accessor :id, :name, :email, :brand, :price_in_dollars, :quantity, :build_id, :user_id, :part
        
        def self.name; 'TestModel'; end
        def new_record?; false; end
        def persisted?; true; end
        def previously_new_record?; false; end
        def changed_attributes; {}; end
      end
    end

    describe '#log_model_summary edge cases' do
      it 'handles missing id gracefully for generic models' do
        instance = test_model.new
        instance.define_singleton_method(:id) { raise NoMethodError, "undefined method 'id'" }
        
        summary = instance.send(:log_model_summary)
        expect(summary).to eq('ID:new')
      end

      it 'handles missing price_in_dollars for parts' do
        instance = test_model.new
        instance.define_singleton_method(:class) { Cpu }
        instance.brand = 'Intel'
        instance.name = 'i7-13700K'
        instance.define_singleton_method(:price_in_dollars) { raise NoMethodError }
        
        summary = instance.send(:log_model_summary)
        expect(summary).to eq('Intel i7-13700K - $N/A')
      end

      it 'handles BuildItem with nil part gracefully' do
        instance = test_model.new
        instance.define_singleton_method(:class) { BuildItem }
        instance.quantity = 1
        instance.build_id = 123
        instance.part = nil
        
        summary = instance.send(:log_model_summary)
        expect(summary).to eq(' x1 in Build:123')
      end

      it 'handles empty changed_attributes' do
        instance = test_model.new
        instance.id = 999
        instance.define_singleton_method(:changed_attributes) { {} }
        instance.define_singleton_method(:new_record?) { false }
        
        expect(Rails.logger).to receive(:info).with('[TESTMODEL] Updating ID:999 - Changed: ')
        instance.send(:log_model_save_attempt)
      end
    end

    describe 'error handling in with_query_logging' do
      let(:test_class) do
        Class.new do
          extend DatabaseLogger::ClassMethods
          def self.name; 'ErrorTestModel'; end
        end
      end

      it 'handles results that are not arrays or countable' do
        allow(Time).to receive(:current).and_return(Time.parse('2025-01-01 00:00:00'), Time.parse('2025-01-01 00:00:00.025'))
        
        result = { data: 'some_data' }
        
        expect(Rails.logger).to receive(:debug).with('[ERRORTESTMODEL_QUERY] Starting: hash result query')
        expect(Rails.logger).to receive(:debug).with('[ERRORTESTMODEL_QUERY] Completed: hash result query - 1 records in 25.0ms')
        
        returned_result = test_class.with_query_logging('hash result query') { result }
        expect(returned_result).to eq(result)
      end

      it 'handles nil results' do
        allow(Time).to receive(:current).and_return(Time.parse('2025-01-01 00:00:00'), Time.parse('2025-01-01 00:00:00.015'))
        
        result = nil
        
        expect(Rails.logger).to receive(:debug).with('[ERRORTESTMODEL_QUERY] Starting: nil result query')
        expect(Rails.logger).to receive(:debug).with('[ERRORTESTMODEL_QUERY] Completed: nil result query - 1 records in 15.0ms')
        
        returned_result = test_class.with_query_logging('nil result query') { result }
        expect(returned_result).to be_nil
      end

      it 'handles string results' do
        allow(Time).to receive(:current).and_return(Time.parse('2025-01-01 00:00:00'), Time.parse('2025-01-01 00:00:00.035'))
        
        result = 'string result'
        
        expect(Rails.logger).to receive(:debug).with('[ERRORTESTMODEL_QUERY] Starting: string query')
        expect(Rails.logger).to receive(:debug).with('[ERRORTESTMODEL_QUERY] Completed: string query - 1 records in 35.0ms')
        
        returned_result = test_class.with_query_logging('string query') { result }
        expect(returned_result).to eq(result)
      end
    end
  end

  describe 'Rails integration' do
    it 'logs initialization message' do
      # This is tested by checking that the file contains the log statement
      file_content = File.read(Rails.root.join('app', 'lib', 'database_logger.rb'))
      expect(file_content).to include('Rails.logger.info "[INITIALIZER] Database logging module loaded"')
    end
  end
end

RSpec.describe "LoggingHelpers + MemoryLogger + PerformanceMonitor" do
  let(:logger_double) { instance_double(Logger, info: true, warn: true, debug: true, error: true) }
  before { allow(Rails).to receive(:logger).and_return(logger_double) }

  class DummyThing
    include LoggingHelpers
    attr_accessor :id
    def initialize(id=nil); @id = id; end
  end

  it "class and instance helpers log as expected" do
    # Class method
    DummyThing.log_class_action("Boot", foo: 1)
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[DUMMYTHING] Boot:", "foo", "1")).at_least(:once)

    # Instance action without id
    DummyThing.new.log_action("do", x: 1)
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[DUMMYTHING] do:", "x", "1")).at_least(:once)

    # Instance action with id
    DummyThing.new(42).log_action("do", y: 2)
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[DUMMYTHING ID:42] do:", "y", "2")).at_least(:once)

    # Error logging (message + context + backtrace)
    err = RuntimeError.new("kaboom")
    err.set_backtrace(%w[a.rb:1 b.rb:2 c.rb:3])
    DummyThing.new(7).log_error(err, action: "test")
    expect(logger_double).to have_received(:error)
      .with("[DUMMYTHING ID:7] ERROR: kaboom").at_least(:once)
    expect(logger_double).to have_received(:error)
      .with(a_string_including("[DUMMYTHING ID:7] CONTEXT:", "action", "test")).at_least(:once)
    expect(logger_double).to have_received(:error)
      .with(a_string_starting_with("[DUMMYTHING ID:7] BACKTRACE: a.rb:1")).at_least(:once)

    # User/business/security/api helpers
    DummyThing.new.log_user_activity(9, "clicked", btn: "save")
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[USER_ACTIVITY] User:9 - clicked:", "btn", "save")).at_least(:once)

    DummyThing.new.log_business_logic("build_created", id: 1)
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[BUSINESS_LOGIC] build_created:", "id", "1")).at_least(:once)

    DummyThing.new.log_security_event("xss_detected", :warn, path: "/q")
    expect(logger_double).to have_received(:warn)
      .with(a_string_including("[SECURITY] xss_detected:", "path", "/q")).at_least(:once)

    DummyThing.new.log_api_interaction("Payments", "charge", {amount: 5}, {status: "ok"})
    expect(logger_double).to have_received(:info)
      .with("[API] Payments - charge").at_least(:once)
    expect(logger_double).to have_received(:debug)
      .with(a_string_starting_with("[API_REQUEST] Payments:")).at_least(:once)
    expect(logger_double).to have_received(:debug)
      .with(a_string_starting_with("[API_RESPONSE] Payments:")).at_least(:once)
  end

  it "performance helpers log fast vs slow paths" do
    thing = DummyThing.new(5)

    # fast (<=100ms)
    t0 = Time.current; t1 = t0 + 0.05
    allow(Time).to receive(:current).and_return(t0, t1)
    res = thing.log_performance("fast op") { :ok }
    expect(res).to eq(:ok)
    expect(logger_double).to have_received(:debug)
      .with(a_string_including("[DUMMYTHING ID:5] PERFORMANCE: fast op took")).at_least(:once)

    # slow (>100ms)
    t2 = Time.current; t3 = t2 + 0.201
    allow(Time).to receive(:current).and_return(t2, t3)
    thing.log_performance("slow op") { :ok }
    expect(logger_double).to have_received(:warn)
      .with(a_string_including("[DUMMYTHING ID:5] SLOW_OPERATION: slow op took")).at_least(:once)
  end

  it "log_database_query logs duration and slow query warning at 500ms" do
    # fast
    t0 = Time.current; t1 = t0 + 0.2
    allow(Time).to receive(:current).and_return(t0, t1)
    DummyThing.new.log_database_query("users/index") { 123 }
    expect(logger_double).to have_received(:debug)
      .with(a_string_including("[DATABASE] users/index")).at_least(:once)

    # slow
    t2 = Time.current; t3 = t2 + 0.6
    allow(Time).to receive(:current).and_return(t2, t3)
    DummyThing.new.log_database_query("users/slow") { 1 }
    expect(logger_double).to have_received(:warn)
      .with(a_string_including("[SLOW_QUERY] users/slow took")).at_least(:once)
  end

  it "MemoryLogger.log_memory_usage logs GC/memory line (skip ps on Windows)" do
    stub_const("RUBY_PLATFORM", "mswin") # avoids backtick `ps`
    MemoryLogger.log_memory_usage("TEST")
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[MEMORY TEST] Objects:", "GC Count:")).at_least(:once)
  end

  it "PerformanceMonitor.monitor_action logs performance and slow-action branch" do
    controller = "Builds"; action = "index"

    # fast
    t0 = Time.current; t1 = t0 + 0.2
    allow(Time).to receive(:current).and_return(t0, t1)
    out = PerformanceMonitor.monitor_action(controller, action) { :ok }
    expect(out).to eq(:ok)
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[PERFORMANCE] Builds#index completed in")).at_least(:once)

    # slow (>500ms)
    t2 = Time.current; t3 = t2 + 0.75
    allow(Time).to receive(:current).and_return(t2, t3)
    PerformanceMonitor.monitor_action(controller, action) { :ok }
    expect(logger_double).to have_received(:warn)
      .with(a_string_including("[SLOW_ACTION] Builds#index took")).at_least(:once)
  end
end