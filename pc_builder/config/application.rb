require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PcBuilder
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Enhanced logging configuration
    config.autoload_paths += %W[#{config.root}/app/lib]
    
    # Load custom logging modules
    config.eager_load_paths += %W[#{config.root}/app/lib]
    
    # Configure log tags for better request tracking
    config.log_tags = [
      :request_id,
      ->(req) { "IP:#{req.remote_ip}" },
      ->(req) { "User:#{req.session[:user_id] || 'guest'}" }
    ]
    
    # Application-wide logging settings
    config.log_level = ENV.fetch('RAILS_LOG_LEVEL', Rails.env.production? ? :info : :debug).to_sym
    
    # Configure Active Record query logging
    config.active_record.verbose_query_logs = !Rails.env.production?
    config.active_record.query_log_tags_enabled = true
    
    # Custom application name for logging
    config.application_name = 'PC Builder'
    
    # Log application startup
    config.after_initialize do
      Rails.logger.info "[APPLICATION] PC Builder application initialized successfully"
      Rails.logger.info "[APPLICATION] Environment: #{Rails.env}"
      Rails.logger.info "[APPLICATION] Log Level: #{Rails.logger.level}"
    end
  end
end
