class BuildsController < ApplicationController
  # Allow browsing and creating builds without authentication
  # Only require auth for saving/sharing builds
  skip_before_action :authenticate_user!, only: [:index, :show, :new, :create, :shared]
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
    
    # Set user if logged in, otherwise create anonymous build
    @build.user = current_user if current_user

    if @build.save
      respond_to do |format|
        format.html { redirect_to build_path(@build), notice: 'Build was successfully created.' }
        format.json { render json: { success: true, build_id: @build.id, message: 'Build created successfully' } }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @build.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # Sharing functionality - requires authentication
  def share
    @build = Build.find(params[:id])
    
    # Only allow sharing if user is logged in and owns the build or build is anonymous
    unless current_user && (@build.user == current_user || @build.user.nil?)
      return render json: { error: 'Unauthorized' }, status: :unauthorized
    end

    components_data = JSON.parse(params[:components_data] || '{}')
    build_data = @build.create_shareable_data!(components_data)
    
    share_url = @build.share_url(request.base_url)
    
    Rails.logger.info "[SHARE] Build #{@build.id} shared by user #{current_user.id}"
    
    render json: {
      success: true,
      share_url: share_url,
      share_token: @build.share_token,
      build_data: build_data
    }
  rescue JSON::ParserError => e
    Rails.logger.error "[SHARE] Invalid JSON in components_data: #{e.message}"
    render json: { error: 'Invalid component data' }, status: :bad_request
  rescue => e
    Rails.logger.error "[SHARE] Failed to share build: #{e.message}"
    render json: { error: 'Failed to create share link' }, status: :internal_server_error
  end

  # View shared build - no authentication required
  def shared
    @build = Build.find(params[:id])
    
    unless @build.shared? && @build.share_token == params[:token]
      flash[:error] = "Invalid or expired share link"
      redirect_to root_path and return
    end

    @shared_data = @build.parsed_shared_data
    Rails.logger.info "[SHARED] Viewing shared build #{@build.id} with token #{params[:token]}"
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
end
