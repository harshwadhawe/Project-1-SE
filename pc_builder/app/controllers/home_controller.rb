class HomeController < ApplicationController
  # Allow home page access without authentication
  skip_before_action :authenticate_user!, only: [:index]
  before_action :log_home_action

  def index
    Rails.logger.info "[HOME INDEX] Loading homepage for user: #{current_user&.id || 'guest'}"
    
    @categories = {
      "Cpu"        => Cpu,
      "GPU"        => Gpu,
      "Motherboard"=> Motherboard,
      "Memory"     => Memory,
      "Storage"    => Storage,
      "Cooler"     => Cooler,
      "PcCase"       => PcCase,
      "PSU"        => Psu
    }
    
    Rails.logger.info "[HOME INDEX] Loading sample parts from #{@categories.count} categories"

    # load a few parts from each category
    @sample_parts = {}
    total_sample_parts = 0
    @categories.each do |name, klass|
      @sample_parts[name] = klass.limit(3)
      count = @sample_parts[name].count
      total_sample_parts += count
      Rails.logger.debug "[HOME INDEX] Loaded #{count} sample #{name} parts"
    end
    
    Rails.logger.info "[HOME INDEX] Loaded #{total_sample_parts} total sample parts"

    @recent_builds = Build.order(created_at: :desc).limit(3)
    Rails.logger.info "[HOME INDEX] Loaded #{@recent_builds.count} recent builds"
    
    # Log recent build details
    @recent_builds.each do |build|
      Rails.logger.debug "[HOME INDEX] Recent build: '#{build.name}' by user #{build.user_id} with #{build.parts.count} parts"
    end
  end

  private

  def log_home_action
    Rails.logger.info "[HOME CONTROLLER] Action: #{action_name}, User: #{current_user&.id || 'guest'}"
  end
end
