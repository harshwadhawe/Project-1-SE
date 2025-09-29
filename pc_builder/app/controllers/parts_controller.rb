class PartsController < ApplicationController
  before_action :log_parts_action

  def index
    Rails.logger.info "[PARTS INDEX] User: #{current_user&.id || 'guest'}, Query param: #{params[:q].inspect}"
    
    if params[:q].present?
      Rails.logger.info "[PARTS INDEX] Filtering parts by type: #{params[:q]}"
      @parts = Part.where(type: params[:q]).order(:brand, :name)
      Rails.logger.info "[PARTS INDEX] Found #{@parts.count} parts of type '#{params[:q]}'"
    else
      Rails.logger.info "[PARTS INDEX] Loading all parts"
      @parts = Part.order(:type, :brand, :name)
      Rails.logger.info "[PARTS INDEX] Found #{@parts.count} total parts"
    end
    
    # Log part type distribution for debugging
    if @parts.respond_to?(:group)
      type_counts = @parts.group(:type).count
      Rails.logger.debug "[PARTS INDEX] Part distribution: #{type_counts.inspect}"
    end
  end

  def show
    Rails.logger.info "[PARTS SHOW] Loading part ID: #{params[:id]} for user: #{current_user&.id || 'guest'}"
    @part = Part.find(params[:id])
    Rails.logger.info "[PARTS SHOW] Successfully loaded part: #{@part.type} - #{@part.brand} #{@part.name}"
    Rails.logger.debug "[PARTS SHOW] Part details - Price: #{@part.price_in_dollars}, Wattage: #{@part.wattage}W"
  end


  private

  def log_parts_action
    Rails.logger.info "[PARTS CONTROLLER] Action: #{action_name}, User: #{current_user&.id || 'guest'}"
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
