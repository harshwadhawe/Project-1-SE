# Enhanced logging configuration for PC Builder application
# This file sets up additional logging capabilities and custom loggers

Rails.application.configure do
  # Custom log formatters
  class DetailedFormatter < Logger::Formatter
    def call(severity, time, progname, msg)
      formatted_time = time.strftime("%Y-%m-%d %H:%M:%S.%3N")
      thread_id = Thread.current.object_id.to_s(36)[-4..-1]
      "[#{formatted_time}] #{severity.ljust(5)} [#{thread_id}] #{progname}: #{msg}\n"
    end
  end

  # Custom log levels and categories
  module CustomLogging
    extend ActiveSupport::Concern

    class_methods do
      def log_user_action(user_id, action, details = {})
        Rails.logger.info "[USER_ACTION] User #{user_id}: #{action} - #{details.inspect}"
      end

      def log_performance_metric(metric_name, value, unit = 'ms')
        Rails.logger.info "[PERFORMANCE] #{metric_name}: #{value}#{unit}"
      end

      def log_business_event(event_type, data = {})
        Rails.logger.info "[BUSINESS] #{event_type}: #{data.inspect}"
      end

      def log_security_event(event_type, details = {})
        Rails.logger.warn "[SECURITY] #{event_type}: #{details.inspect}"
      end

      def log_external_api(service, action, response_time = nil, status = nil)
        msg = "[EXTERNAL_API] #{service}: #{action}"
        msg += " - #{response_time}ms" if response_time
        msg += " - Status: #{status}" if status
        Rails.logger.info msg
      end
    end
  end

  # Include custom logging in ApplicationRecord and ApplicationController
  ActiveRecord::Base.send(:include, CustomLogging) if defined?(ActiveRecord::Base)
  if defined?(ApplicationController)
    ApplicationController.send(:include, CustomLogging)
  end

  # Configure different log levels based on environment
  case Rails.env
  when 'development'
    Rails.logger.level = Logger::DEBUG
    
  when 'test'
    Rails.logger.level = Logger::WARN
    
  when 'production'
    Rails.logger.level = Logger::INFO
    
    # Log important application metrics
    Rails.application.config.after_initialize do
      Rails.logger.info "[APPLICATION] PC Builder application started"
      Rails.logger.info "[APPLICATION] Rails version: #{Rails.version}"
      Rails.logger.info "[APPLICATION] Ruby version: #{RUBY_VERSION}"
      Rails.logger.info "[APPLICATION] Environment: #{Rails.env}"
      
      # Log database configuration (safely)
      if defined?(ActiveRecord::Base)
        db_config = ActiveRecord::Base.connection_db_config
        Rails.logger.info "[DATABASE] Adapter: #{db_config.adapter}"
        Rails.logger.info "[DATABASE] Database: #{db_config.database}"
      end
    end
  end

  # Error tracking and monitoring
  class ErrorTracker
    def self.track(exception, context = {})
      Rails.logger.error "[ERROR_TRACKER] #{exception.class}: #{exception.message}"
      Rails.logger.error "[ERROR_CONTEXT] #{context.inspect}" if context.any?
      Rails.logger.error "[ERROR_BACKTRACE] #{exception.backtrace&.first(10)&.join("\n")}"
      
      # Here you could integrate with external services like Sentry, Bugsnag, etc.
      # Example: Sentry.capture_exception(exception, extra: context)
    end
  end

  # Make ErrorTracker available globally
  Object.const_set('ErrorTracker', ErrorTracker) unless defined?(ErrorTracker)
end

# Log application startup
Rails.logger.info "[INITIALIZER] Enhanced logging configuration loaded" if Rails.logger