class BuildsController < ApplicationController
  before_action :load_categories, only: [:new, :create]
  before_action :log_build_action

  def index
    Rails.logger.info "[BUILDS INDEX] Loading builds list for user: #{current_user&.id || 'guest'}"
    @builds = Build.order(created_at: :desc)
    Rails.logger.info "[BUILDS INDEX] Found #{@builds.count} builds"
  end

  def show
    Rails.logger.info "[BUILD SHOW] Loading build ID: #{params[:id]} for user: #{current_user&.id || 'guest'}"
    @build = Build.find(params[:id])
    @build_id = @build["id"]
    @sample_parts = {}
    @categories = {
      "Cpu"        => Cpu,
      "Gpu"        => Gpu,
      "Motherboard"=> Motherboard,
      "Memory"     => Memory,
      "Storage"    => Storage,
      "Cooler"     => Cooler,
      "PcCase"       => PcCase,
      "Psu"        => Psu
    }
    @build.parts.each do |part|
        @sample_parts[part.class.name] = part
        Rails.logger.info "#{part.name}"
        Rails.logger.info "#{part.brand}"
        Rails.logger.info "#{part.class.name}"
        # count = @sample_parts[name].count
        # Rails.logger.debug "[BUILDS INDEX] Loaded #{count} sample #{name} parts"
    end
    Rails.logger.info "#{@sample_parts}"
    Rails.logger.info "[BUILD SHOW] Successfully loaded build '#{@build.name}' with #{@build.parts.count} parts"
  end

  def new
    Rails.logger.info "[BUILD NEW] Starting new build creation for user: #{current_user&.id || 'guest'}"
    @build = Build.new
    Rails.logger.info "[BUILD NEW] Loaded #{@parts_by_category.values.flatten.count} parts across #{@categories.count} categories"
  end

  def create
    @build = Build.new(build_params)

    if @build.save
      redirect_to build_path(@build), notice: 'Build was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def log_build_action
    Rails.logger.info "[BUILD CONTROLLER] Action: #{action_name}, User: #{current_user&.id || 'guest'}"
  end

  # IMPORTANT: do not permit :part_ids or :quantities here (they're not columns)
  def build_params
    permitted = params.require(:build).permit(:name)
    Rails.logger.debug "[BUILD PARAMS] Permitted params: #{permitted.inspect}"
    permitted
  end

  def load_categories
    Rails.logger.debug "[LOAD CATEGORIES] Loading part categories and parts"
    @categories = {
      "CPU"         => Cpu,
      "GPU"         => Gpu,
      "Motherboard" => Motherboard,
      "Memory"      => Memory,
      "Storage"     => Storage,
      "Cooler"      => Cooler,
      "PcCase"        => PcCase,
      "PSU"         => Psu
    }
    @parts_by_category = @categories.transform_values { |k| k.order(:brand, :name).limit(50) }
    
    total_parts = @parts_by_category.values.flatten.count
    Rails.logger.info "[LOAD CATEGORIES] Loaded #{@categories.count} categories with #{total_parts} total parts"
  end

  # --- quick auth helpers (see B below for Sessions controller) ---
  def current_user
    return @current_user if defined?(@current_user)
    
    @current_user = User.find_by(id: session[:user_id])
    Rails.logger.debug "[AUTH] Current user lookup: #{@current_user ? "found user ID #{@current_user.id}" : 'no user found'}"
    @current_user
  end

  def default_user
    Rails.logger.info "[AUTH] Creating/finding default user"
    User.find_or_create_by!(email: "harsh@example.com") { |u| u.name = "Harsh" }.tap do |u|
      session[:user_id] ||= u.id
      Rails.logger.info "[AUTH] Set session user_id to #{u.id} for default user"
    end
  end
end
