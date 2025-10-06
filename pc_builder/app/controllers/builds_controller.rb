class BuildsController < ApplicationController
  # Public pages
  skip_before_action :authenticate_user!, only: [:index, :show, :new, :create, :shared]

  before_action :log_build_action
  before_action :set_build, only: [:show, :edit, :update, :destroy]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]
  before_action :load_categories, only: [:new, :create, :edit, :update]

  def index
    Rails.logger.info "[BUILDS INDEX] Loading builds list for user: #{current_user&.id || 'guest'}"
    @builds = Build.order(created_at: :desc)
    Rails.logger.info "[BUILDS INDEX] Found #{@builds.count} builds"
  end

  def show
    Rails.logger.info "[BUILD SHOW] Loading build ID: #{params[:id]} for user: #{current_user&.id || 'guest'}"
    @build_id = @build["id"]
    @sample_parts = {}
    @categories = {
      "Cpu" => Cpu, "Gpu" => Gpu, "Motherboard" => Motherboard, "Memory" => Memory,
      "Storage" => Storage, "Cooler" => Cooler, "PcCase" => PcCase, "Psu" => Psu
    }
    @build.parts.each do |part|
      @sample_parts[part.class.name] = part
      Rails.logger.info "#{part.name}"
      Rails.logger.info "#{part.brand}"
      Rails.logger.info "#{part.class.name}"
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
    @build.user = current_user if current_user

    if @build.save
      respond_to do |format|
        format.html { redirect_to build_path(@build), notice: 'Build was successfully created.' }
        format.json { render json: { success: true, build_id: @build.id, message: 'Build created successfully' } }
      end
    else
      respond_to do |format|
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: { success: false, errors: @build.errors.full_messages }, status: :unprocessable_content }
      end
    end
  end

  def edit
    Rails.logger.info "[BUILD EDIT] Editing build ID: #{@build.id} by user: #{current_user&.id}"
    render :new
  end


  def update
    if @build.update(build_params)
      Rails.logger.info "[BUILD UPDATE] Updated build ID: #{@build.id} by user: #{current_user&.id}"
      redirect_to @build, notice: 'Build was successfully updated.'
    else
      Rails.logger.warn "[BUILD UPDATE] Failed update for build ID: #{@build.id} - #{ @build.errors.full_messages.join(', ') }"
      render :new, status: :unprocessable_content   # ← was :edit
    end
  end

  def destroy
    name = @build.name
    if @build.destroy
      Rails.logger.warn "[BUILD DESTROY] Destroyed build ID: #{@build.id} - '#{name}'"
      redirect_to builds_path, notice: 'Build was successfully deleted.'
    else
      Rails.logger.error "[BUILD DESTROY] Failed to destroy build ID: #{@build.id}"
      redirect_to @build, alert: 'Failed to delete build.'
    end
  end


  # ---------- /NEW STUFF ----------


  def share
    @build = Build.find_by(id: params[:id]) ||
            Build.create!(name: params.dig(:build, :name).presence || 'Untitled Build', user: current_user)

    # Normalize incoming components
    raw = params[:components_data]
    components_data =
      if raw.blank?
        {}
      elsif raw.is_a?(String)
        JSON.parse(raw)
      elsif defined?(ActionController::Parameters) && raw.is_a?(ActionController::Parameters)
        raw.to_unsafe_h
      elsif raw.is_a?(Hash)
        raw
      else
        {}
      end

    # Prepare a portable payload
    build_data = @build.create_shareable_data!(components_data) # keep your existing aggregator if you have it

    payload = {
      "name"           => build_data["name"] || @build.name || "Untitled Build",
      "components"     => build_data["components"] || components_data,
      "parts_count"    => build_data["parts_count"] || (components_data&.size || 0),
      "total_cost"     => build_data["total_cost"] || 0,       # cents
      "total_wattage"  => build_data["total_wattage"] || 0,
      "created_at"     => (@build.created_at || Time.current).iso8601,
      "shared_at"      => Time.current.iso8601,
      "user_name"      => (current_user&.respond_to?(:display_name) && current_user.display_name.presence) ||
                          current_user&.email ||
                          "Guest"
    }

    token = Rails.application.message_verifier(:build_share).generate(payload)

    # Optional: persist for analytics/back-compat; not required for rendering
    @build.update_columns(share_token: token, shared_data: payload.to_json, shared_at: Time.current) rescue nil

    share_url = url_for(controller: :builds, action: :shared, id: @build.id, token: token, only_path: false)

    render json: { success: true, share_url:, share_token: token, build_data: payload }
  rescue JSON::ParserError => e
    Rails.logger.error "[SHARE] Invalid JSON in components_data: #{e.message}"
    render json: { error: 'Invalid component data' }, status: :bad_request
  rescue => e
    Rails.logger.error "[SHARE] Failed to create share link: #{e.message}"
    render json: { error: 'Failed to create share link' }, status: :internal_server_error
  end



  def shared
    @shared_data = {}

    if params[:token].present?
      begin
        @shared_data = Rails.application.message_verifier(:build_share).verify(params[:token]) || {}
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        Rails.logger.warn "[SHARED] Invalid token"
      end
    end

    # Optional DB fallback (for legacy links or when token omitted)
    if @shared_data.blank?
      @build = Build.find_by(id: params[:id])
      if @build&.shared_data.present?
        @shared_data = JSON.parse(@build.shared_data) rescue {}
      end
    end

    if @shared_data.blank?
      return render file: Rails.root.join('public/404.html'), status: :not_found, layout: true
    end

    # If you also want @build for counts, this is safe (nil if DB dropped)
    @build ||= Build.find_by(id: params[:id])
  end

  private

  def set_build
    @build = Build.find(params[:id])
  end

  def authorize_owner!
    unless current_user && (@build.user_id == current_user.id || @build.user_id.nil?)
      Rails.logger.warn "[AUTHZ] User #{current_user&.id || 'guest'} not authorized for build #{@build&.id}"
      respond_to do |format|
        format.html { redirect_to(@build ? build_path(@build) : builds_path, alert: 'Unauthorized') }
        format.json { render json: { error: 'Unauthorized' }, status: :unauthorized }
      end
    end
  end

  def log_build_action
    Rails.logger.info "[BUILD CONTROLLER] Action: #{action_name}, User: #{current_user&.id || 'guest'}"
  end

  def build_params
    permitted = params.require(:build).permit(:name)
    Rails.logger.debug "[BUILD PARAMS] Permitted params: #{permitted.inspect}"
    permitted
  end

  def load_categories
    Rails.logger.debug "[LOAD CATEGORIES] Loading part categories and parts"
    @categories = {
      "CPU" => Cpu, "GPU" => Gpu, "Motherboard" => Motherboard, "Memory" => Memory,
      "Storage" => Storage, "Cooler" => Cooler, "PcCase" => PcCase, "PSU" => Psu
    }
    @parts_by_category = @categories.transform_values { |k| k.order(:brand, :name).limit(50) }
    total_parts = @parts_by_category.values.flatten.count
    Rails.logger.info "[LOAD CATEGORIES] Loaded #{@categories.count} categories with #{total_parts} total parts"
  end
end
