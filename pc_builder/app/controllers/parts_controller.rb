class PartsController < ApplicationController
  # Allow browsing parts without authentication
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :log_parts_action

def index
  Rails.logger.info "[PARTS INDEX] User: #{current_user&.id || 'guest'}, Params: #{params.to_unsafe_h.slice(:type, :brand, :q, :min_price, :max_price, :sort).inspect}"

  @parts = Part.all
  parts_table = Part.arel_table

  # ---- Type filter (new :type, but accept old :q if it matches a type) ----
  if params[:type].present?
    Rails.logger.info "[PARTS INDEX] Filtering by type: #{params[:type]}"
    @parts = @parts.where(type: params[:type])
  elsif params[:q].present?
    # If q looks like a type, treat it as type (back-compat with your old UI)
    types = Part.distinct.pluck(:type)
    if types.include?(params[:q])
      Rails.logger.info "[PARTS INDEX] (compat) Filtering by type via q=: #{params[:q]}"
      @parts = @parts.where(type: params[:q])
      params[:type] = params[:q] # so the view shows the selected option
    end
  end

  # ---- Brand filter (case-insensitive, works on PG/SQLite) ----
  if params[:brand].present?
    brand_q = "%#{params[:brand].downcase}%"
    Rails.logger.info "[PARTS INDEX] Filtering by brand ILIKE #{brand_q.inspect}"
    @parts = @parts.where(parts_table[:brand].lower.matches(brand_q))
  end

  # ---- Name/keyword search (if :q is present and wasn't used as a type) ----
  if params[:q].present? && !(params[:type].present? && params[:type] == params[:q])
    name_q = "%#{params[:q].downcase}%"
    Rails.logger.info "[PARTS INDEX] Searching name ILIKE #{name_q.inspect}"
    @parts = @parts.where(parts_table[:name].lower.matches(name_q))
  end

  # ---- Price filters (expects dollars in params; converts to cents) ----
  if params[:min_price].present?
    min_cents = (params[:min_price].to_f * 100).to_i
    Rails.logger.info "[PARTS INDEX] Min price_cents >= #{min_cents}"
    @parts = @parts.where(parts_table[:price_cents].gteq(min_cents))
  end
  if params[:max_price].present?
    max_cents = (params[:max_price].to_f * 100).to_i
    Rails.logger.info "[PARTS INDEX] Max price_cents <= #{max_cents}"
    @parts = @parts.where(parts_table[:price_cents].lteq(max_cents))
  end

  # ---- Sorting ----
  case params[:sort]
  when "price_asc"
    @parts = @parts.order(Arel.sql("price_cents ASC NULLS LAST"), :brand, :name)
  when "price_desc"
    @parts = @parts.order(Arel.sql("price_cents DESC NULLS LAST"), :brand, :name)
  when "brand_asc"
    @parts = @parts.order(Arel.sql("LOWER(brand) ASC"), :name)
  when "brand_desc"
    @parts = @parts.order(Arel.sql("LOWER(brand) DESC"), :name)
  else
    Rails.logger.info "[PARTS INDEX] Default ordering"
    @parts = @parts.order(:type, :brand, :name)
  end

  Rails.logger.info  "[PARTS INDEX] Found #{@parts.size} parts after filters"
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
