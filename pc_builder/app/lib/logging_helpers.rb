# Application-wide logging utilities and helpers
# This module provides consistent logging patterns across the PC Builder application

module LoggingHelpers
  extend ActiveSupport::Concern

  included do
    # Include logging helper methods in controllers and models
  end

  module ClassMethods
    def log_class_action(action, details = {})
      Rails.logger.info "[#{self.name.upcase}] #{action}: #{details.inspect}"
    end
  end

  # Instance methods for consistent logging
  def log_action(action, details = {})
    class_name = self.class.name
    id_info = respond_to?(:id) && id ? " ID:#{id}" : ""
    Rails.logger.info "[#{class_name.upcase}#{id_info}] #{action}: #{details.inspect}"
  end

  def log_error(error, context = {})
    class_name = self.class.name
    id_info = respond_to?(:id) && id ? " ID:#{id}" : ""
    Rails.logger.error "[#{class_name.upcase}#{id_info}] ERROR: #{error.message}"
    Rails.logger.error "[#{class_name.upcase}#{id_info}] CONTEXT: #{context.inspect}" if context.any?
    Rails.logger.error "[#{class_name.upcase}#{id_info}] BACKTRACE: #{error.backtrace&.first(5)&.join("\n")}"
  end

  def log_performance(operation_name, &block)
    start_time = Time.current
    result = yield
    duration = (Time.current - start_time) * 1000
    
    class_name = self.class.name
    id_info = respond_to?(:id) && id ? " ID:#{id}" : ""
    
    if duration > 100 # Log operations taking more than 100ms
      Rails.logger.warn "[#{class_name.upcase}#{id_info}] SLOW_OPERATION: #{operation_name} took #{duration.round(2)}ms"
    else
      Rails.logger.debug "[#{class_name.upcase}#{id_info}] PERFORMANCE: #{operation_name} took #{duration.round(2)}ms"
    end
    
    result
  end

  def log_database_query(query_description, &block)
    start_time = Time.current
    result = yield
    duration = (Time.current - start_time) * 1000
    
    Rails.logger.debug "[DATABASE] #{query_description} - #{duration.round(2)}ms"
    
    if duration > 500 # Log slow database queries (> 500ms)
      Rails.logger.warn "[SLOW_QUERY] #{query_description} took #{duration.round(2)}ms"
    end
    
    result
  end

  # User activity logging
  def log_user_activity(user_id, activity, details = {})
    user_info = user_id ? "User:#{user_id}" : "Guest"
    Rails.logger.info "[USER_ACTIVITY] #{user_info} - #{activity}: #{details.inspect}"
  end

  # Business logic logging
  def log_business_logic(event, data = {})
    Rails.logger.info "[BUSINESS_LOGIC] #{event}: #{data.inspect}"
  end

  # Security event logging
  def log_security_event(event, severity = :warn, details = {})
    Rails.logger.send(severity, "[SECURITY] #{event}: #{details.inspect}")
  end

  # API interaction logging
  def log_api_interaction(service, action, request_data = {}, response_data = {})
    Rails.logger.info "[API] #{service} - #{action}"
    Rails.logger.debug "[API_REQUEST] #{service}: #{request_data.inspect}" if request_data.any?
    Rails.logger.debug "[API_RESPONSE] #{service}: #{response_data.inspect}" if response_data.any?
  end
end

# Include logging helpers in ApplicationRecord and ApplicationController
ActiveSupport.on_load(:active_record) do
  include LoggingHelpers
end

ActiveSupport.on_load(:action_controller) do
  include LoggingHelpers
end

# Memory usage monitoring
class MemoryLogger
  def self.log_memory_usage(context = "")
    if defined?(GC)
      gc_stat = GC.stat
      memory_usage = `ps -o pid,vsz,rss -p #{Process.pid}`.split("\n").last.split if RUBY_PLATFORM !~ /mswin|mingw|cygwin/
      
      Rails.logger.info "[MEMORY#{context.present? ? " #{context}" : ""}] " \
                       "Objects: #{gc_stat[:heap_live_slots]}, " \
                       "GC Count: #{gc_stat[:count]}, " \
                       "Memory: #{memory_usage ? "#{memory_usage[2]}KB RSS" : "unknown"}"
    end
  end
end

# Performance monitoring
class PerformanceMonitor
  def self.monitor_action(controller, action, &block)
    start_time = Time.current
    start_memory = MemoryLogger.log_memory_usage("START #{controller}##{action}")
    
    result = yield
    
    duration = (Time.current - start_time) * 1000
    end_memory = MemoryLogger.log_memory_usage("END #{controller}##{action}")
    
    Rails.logger.info "[PERFORMANCE] #{controller}##{action} completed in #{duration.round(2)}ms"
    
    if duration > 500
      Rails.logger.warn "[SLOW_ACTION] #{controller}##{action} took #{duration.round(2)}ms"
    end
    
    result
  end
end

Rails.logger.info "[INITIALIZER] Application logging helpers loaded"