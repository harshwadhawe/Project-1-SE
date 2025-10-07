# frozen_string_literal: true

class BuildItem < ApplicationRecord
  belongs_to :build
  belongs_to :part
  validates :quantity, numericality: { greater_than: 0 }, allow_nil: true

  before_create :log_build_item_creation
  after_create :log_build_item_created
  before_destroy :log_build_item_destruction
  after_validation :log_validation_results
  after_update :log_build_item_updated

  # Custom methods with logging
  def total_cost
    cost = (part.price_cents || 0) * (quantity || 1)
    Rails.logger.debug "[BUILD_ITEM #{id}] Calculated total cost: #{cost} cents (#{quantity} x #{part.price_cents})"
    cost
  end

  def total_wattage
    wattage = (part.wattage || 0) * (quantity || 1)
    Rails.logger.debug "[BUILD_ITEM #{id}] Calculated total wattage: #{wattage}W (#{quantity} x #{part.wattage})"
    wattage
  end

  private

  def log_build_item_creation
    Rails.logger.info "[BUILD_ITEM CREATE] Adding part '#{part&.name}' (ID: #{part_id}) to build '#{build&.name}' (ID: #{build_id}) with quantity: #{quantity || 1}"
  end

  def log_build_item_created
    Rails.logger.info "[BUILD_ITEM CREATED] Successfully created BuildItem ID: #{id} - #{part.name} x#{quantity} in build '#{build.name}'"
  end

  def log_build_item_destruction
    Rails.logger.warn "[BUILD_ITEM DESTROY] Removing BuildItem ID: #{id} - #{part.name} x#{quantity} from build '#{build.name}'"
  end

  def log_validation_results
    if errors.any?
      Rails.logger.warn "[BUILD_ITEM VALIDATION] Validation failed for BuildItem: #{errors.full_messages.join(', ')}"
    else
      Rails.logger.debug '[BUILD_ITEM VALIDATION] Validation passed for BuildItem'
    end
  end

  def log_build_item_updated
    return unless saved_changes.any?

    Rails.logger.info "[BUILD_ITEM UPDATED] BuildItem ID: #{id} updated - Changes: #{saved_changes.except('updated_at').inspect}"
  end
end
