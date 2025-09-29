# app/controllers/parts_controller.rb
class PartsController < ApplicationController
  before_action :log_parts_action
  before_action :set_part, only: :show

  # Whitelist STI types (string class names stored in parts.type)
  PART_TYPES = %w[Cpu Gpu Motherboard Memory Storage Cooler PcCase Psu].freeze
  # Friendly aliases -> STI type
  PART_ALIASES = {
    "cpu" => "Cpu",
    "gpu" => "Gpu",
    "motherboard" => "Motherboard",
    "mb" => "Motherboard",
    "memory" => "Memory",
    "ram" => "Memory",
    "storage" => "Storage",
    "ssd" => "Storage",
    "hdd" => "Storage",
    "cooler" => "Cooler",
    "case" => "PcCase",
    "pccase" => "PcCase",
    "psu" => "Psu",
    "power" => "Psu"
  }.freeze

  def index
    Rails.logger.info "[PARTS INDEX] User: #{current_user&.id || 'guest'}, Query param: #{params[:q].inspect}"

    if params[:q].present?
      safe_type = normalize_type(params[:q])
      if safe_type
        Rails.logger.info "[PARTS INDEX] Filtering parts by type: #{safe_type}"
        @parts = Part.where(type: safe_type).order(:brand, :name)
        Rails.logger.info "[PARTS INDEX] Found #{@parts.count} parts of type '#{safe_type}'"
      else
        Rails.logger.warn "[PARTS INDEX] Invalid type filter: #{params[:q].inspect}"
        flash.now[:alert] = "Unknown part type: #{params[:q]}"
        @parts = Part.order(:type, :brand, :name)
      end
    else
      Rails.logger.info "[PARTS INDEX] Loading all parts"
      @parts = Part.order(:type, :brand, :name)
      Rails.logger.info "[PARTS INDEX] Found #{@parts.count} total parts"
    end

    # Distribution by STI type
    type_counts = @parts.group(:type).count
    Rails.logger.debug "[PARTS INDEX] Part distribution: #{type_counts.inspect}"
  end

  def show
    Rails.logger.info "[PARTS SHOW] Loading part ID: #{params[:id]} for user: #{current_user&.id || 'guest'}"

    type_label = @part.type.presence || @part.class.name
    Rails.logger.info "[PARTS SHOW] Successfully loaded part: #{type_label} - #{@part.brand} #{@part.name}"

    price_str   = @part.respond_to?(:price) && @part.price ? helpers.number_to_currency(@part.price) : "N/A"
    wattage_str = @part.wattage.present? ? "#{@part.wattage}W" : "N/A"

    Rails.logger.debug "[PARTS SHOW] Part details - Price: #{price_str}, Wattage: #{wattage_str}"
  end

  private

  def set_part
    @part = Part.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "[PARTS SHOW] Part not found: id=#{params[:id]}"
    redirect_to parts_path, alert: "Part not found."
  end

  def log_parts_action
    Rails.logger.info "[PARTS CONTROLLER] Action: #{action_name}, User: #{current_user&.id || 'guest'}"
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def normalize_type(raw)
    key = raw.to_s.strip.downcase
    PART_ALIASES[key] || PART_TYPES.find { |t| t.downcase == key }
  end
end
