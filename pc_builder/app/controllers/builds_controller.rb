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
    Rails.logger.info "[BUILD SHOW] Successfully loaded build '#{@build.name}' with #{@build.parts.count} parts"
  end

  def new
    Rails.logger.info "[BUILD NEW] Starting new build creation for user: #{current_user&.id || 'guest'}"
    @build = Build.new
    Rails.logger.info "[BUILD NEW] Loaded #{@parts_by_category.values.flatten.count} parts across #{@categories.count} categories"
  end

  def create
    Rails.logger.info "[BUILD CREATE] Starting build creation with params: #{build_params.inspect}"
    Rails.logger.info "[BUILD CREATE] User: #{current_user&.id || 'creating default user'}"
    
    @build = Build.new(build_params)            # ONLY :name here
    @build.user = current_user || default_user  # attach a user
    
    Rails.logger.info "[BUILD CREATE] Assigned user ID: #{@build.user.id} to build '#{@build.name}'"

    if @build.save
      Rails.logger.info "[BUILD CREATE] Successfully saved build ID: #{@build.id}"
      
      selected_ids = Array(params.dig(:build, :part_ids)).reject(&:blank?)
      qty_hash     = (params.dig(:build, :quantities) || {}) # <- read directly from params
      
      Rails.logger.info "[BUILD CREATE] Adding #{selected_ids.count} parts to build"
      Rails.logger.debug "[BUILD CREATE] Selected part IDs: #{selected_ids.inspect}"
      Rails.logger.debug "[BUILD CREATE] Quantities: #{qty_hash.inspect}"

      selected_ids.each do |pid|
        qty = qty_hash[pid.to_s].presence || "1"
        Rails.logger.debug "[BUILD CREATE] Adding part ID: #{pid}, quantity: #{qty}"
        build_item = BuildItem.create!(build: @build, part_id: pid.to_i, quantity: qty.to_i)
        Rails.logger.debug "[BUILD CREATE] Created BuildItem ID: #{build_item.id}"
      end

      # optional: cache total_wattage
      if @build.respond_to?(:total_wattage)
        total_wattage = @build.parts.sum(:wattage)
        @build.update!(total_wattage: total_wattage)
        Rails.logger.info "[BUILD CREATE] Updated total wattage: #{total_wattage}W"
      end

      Rails.logger.info "[BUILD CREATE] Build '#{@build.name}' created successfully with #{@build.parts.count} parts"
      redirect_to @build, notice: "Build created successfully!"
    else
      Rails.logger.warn "[BUILD CREATE] Failed to save build: #{@build.errors.full_messages.join(', ')}"
      Rails.logger.warn "[BUILD CREATE] Build params were: #{build_params.inspect}"
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
      "Cpu"         => Cpu,
      "Gpu"         => Gpu,
      "Motherboard" => Motherboard,
      "Memory"      => Memory,
      "Storage"     => Storage,
      "Cooler"      => Cooler,
      "PcCase"        => PcCase,
      "Psu"         => Psu
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
