class BuildsController < ApplicationController
  before_action :load_categories, only: [:new, :create]

  def index
    @builds = Build.order(created_at: :desc)
  end

  def show
    @build = Build.find(params[:id])
  end

  def new
    @build = Build.new
  end

  def create
    @build = Build.new(build_params)            # ONLY :name here
    @build.user = current_user || default_user  # attach a user

    if @build.save
      selected_ids = Array(params.dig(:build, :part_ids)).reject(&:blank?)
      qty_hash     = (params.dig(:build, :quantities) || {}) # <- read directly from params

      selected_ids.each do |pid|
        qty = qty_hash[pid.to_s].presence || "1"
        BuildItem.create!(build: @build, part_id: pid.to_i, quantity: qty.to_i)
      end

      # optional: cache total_wattage
      @build.update!(total_wattage: @build.parts.sum(:wattage)) if @build.respond_to?(:total_wattage)

      redirect_to @build, notice: "Build created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # IMPORTANT: do not permit :part_ids or :quantities here (they're not columns)
  def build_params
    params.require(:build).permit(:name)
  end

  def load_categories
    @categories = {
      "CPU"         => Cpu,
      "GPU"         => Gpu,
      "Motherboard" => Motherboard,
      "Memory"      => Memory,
      "Storage"     => Storage,
      "Cooler"      => Cooler,
      "Case"        => PcCase,
      "PSU"         => Psu
    }
    @parts_by_category = @categories.transform_values { |k| k.order(:brand, :name).limit(50) }
  end

  # --- quick auth helpers (see B below for Sessions controller) ---
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def default_user
    User.find_or_create_by!(email: "harsh@example.com") { |u| u.name = "Harsh" }.tap do |u|
      session[:user_id] ||= u.id
    end
  end
end
