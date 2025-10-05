# Database Query Logger
# Monitors and logs database performance and query patterns

module DatabaseLogger
  extend ActiveSupport::Concern

  included do
    # Add callbacks to track database operations
    after_initialize :log_model_initialization, if: :persisted?
    before_save :log_model_save_attempt
    after_save :log_model_saved
    before_destroy :log_model_destroy_attempt
    after_destroy :log_model_destroyed
  end

  module ClassMethods
    def log_query(query_type, conditions = {})
      Rails.logger.debug "[#{self.name.upcase}_QUERY] #{query_type}: #{conditions.inspect}"
    end

    def with_query_logging(description, &block)
      start_time = Time.current
      Rails.logger.debug "[#{self.name.upcase}_QUERY] Starting: #{description}"
      
      result = yield
      
      duration = (Time.current - start_time) * 1000
      count = if result.respond_to?(:count) && !result.is_a?(String)
                result.count 
              elsif result.is_a?(Array)
                result.size
              else
                1
              end
      
      Rails.logger.debug "[#{self.name.upcase}_QUERY] Completed: #{description} - #{count} records in #{duration.round(2)}ms"
      
      if duration > 100
        Rails.logger.warn "[#{self.name.upcase}_SLOW_QUERY] #{description} took #{duration.round(2)}ms"
      end
      
      result
    end
  end

  private

  def log_model_initialization
    Rails.logger.debug "[#{self.class.name.upcase}] Initialized: #{log_model_summary}"
  end

  def log_model_save_attempt
    if new_record?
      Rails.logger.info "[#{self.class.name.upcase}] Creating: #{log_model_summary}"
    else
      changes_summary = changed_attributes.keys.join(', ')
      Rails.logger.info "[#{self.class.name.upcase}] Updating ID:#{id} - Changed: #{changes_summary}"
    end
  end

  def log_model_saved
    if previously_new_record?
      Rails.logger.info "[#{self.class.name.upcase}] Created: ID:#{id} - #{log_model_summary}"
    else
      Rails.logger.info "[#{self.class.name.upcase}] Updated: ID:#{id}"
    end
  end

  def log_model_destroy_attempt
    Rails.logger.warn "[#{self.class.name.upcase}] Destroying: ID:#{id} - #{log_model_summary}"
  end

  def log_model_destroyed
    Rails.logger.warn "[#{self.class.name.upcase}] Destroyed: ID:#{id}"
  end

  def log_model_summary
    # Override in specific models to provide meaningful summaries
    case self.class.name
    when 'User'
      "#{name} (#{email})"
    when 'Build'
      "#{name} by User:#{user_id}"
    when 'Part', 'Cpu', 'Gpu', 'Motherboard', 'Memory', 'Storage', 'Cooler', 'PcCase', 'Psu'
      "#{brand} #{name} - $#{price_in_dollars rescue 'N/A'}"
    when 'BuildItem'
      "#{part&.name} x#{quantity} in Build:#{build_id}"
    else
      "ID:#{id rescue 'new'}"
    end
  end
end

Rails.logger.info "[INITIALIZER] Database logging module loaded"