class Build < ApplicationRecord
  belongs_to :user, optional: true
  has_many :build_items, dependent: :destroy
  has_many :parts, through: :build_items

  validates :name, presence: true


  # NEW: cache item count before any dependent destroys kick in
  set_callback :destroy, :before, :cache_build_item_count, prepend: true
  
  before_create :log_build_creation
  after_create :log_build_created
  before_destroy :log_build_destruction
  after_validation :log_validation_results
  after_update :log_build_updated

  # Custom methods with logging
  def total_cost
    cost = parts.sum(&:price_cents) || 0
    Rails.logger.debug "[BUILD #{id}] Calculated total cost: #{cost} cents"
    cost
  end

  def total_wattage
    wattage = parts.sum(&:wattage) || 0
    Rails.logger.debug "[BUILD #{id}] Calculated total wattage: #{wattage}W"
    wattage
  end

  def parts_summary
    summary = parts.group(:type).count
    Rails.logger.debug "[BUILD #{id}] Parts summary: #{summary.inspect}"
    summary
  end

  # Sharing functionality
  def generate_share_token!
    self.share_token = SecureRandom.urlsafe_base64(12)
    self.shared_at = Time.current
    save!
    Rails.logger.info "[BUILD #{id}] Generated share token: #{share_token}"
    share_token
  end

  def create_shareable_data!(components_data = {})
    build_data = {
      id: id,
      name: name,
      components: components_data,
      total_cost: total_cost,
      total_wattage: total_wattage,
      parts_count: parts.count,
      user_name: user&.name || "Anonymous",
      created_at: created_at,
      shared_at: Time.current
    }
    
    self.shared_data = build_data.to_json
    generate_share_token!
    
    Rails.logger.info "[BUILD #{id}] Created shareable data with #{components_data.keys.count} components"
    build_data
  end

  def shared?
    share_token.present? && shared_at.present?
  end

  def share_url(base_url = "")
    return nil unless shared?
    "#{base_url}/builds/#{id}/shared?token=#{share_token}"
  end

  def parsed_shared_data
    return {} unless shared_data.present?
    JSON.parse(shared_data)
  rescue JSON::ParserError => e
    Rails.logger.error "[BUILD #{id}] Failed to parse shared data: #{e.message}"
    {}
  end

  private

  def cache_build_item_count
    @build_items_count_at_destroy = BuildItem.where(build_id: id).count
  end


  def log_build_creation
    Rails.logger.info "[BUILD CREATE] Creating new build: '#{name}' for user ID: #{user_id || 'none'}"
  end

  def log_build_created
    Rails.logger.info "[BUILD CREATED] Successfully created build ID: #{id} - '#{name}'"
  end

  def log_build_destruction
    # use cached value if present; fall back to live count
    count = @build_items_count_at_destroy || BuildItem.where(build_id: id).count
    Rails.logger.warn "[BUILD DESTROY] Destroying build ID: #{id} - '#{name}' with #{count} items"
  end

  def log_validation_results
    if errors.any?
      Rails.logger.warn "[BUILD VALIDATION] Validation failed for build '#{name}': #{errors.full_messages.join(', ')}"
    else
      Rails.logger.debug "[BUILD VALIDATION] Validation passed for build '#{name}'"
    end
  end

  def log_build_updated
    if saved_changes.any?
      Rails.logger.info "[BUILD UPDATED] Build ID: #{id} updated - Changes: #{saved_changes.except('updated_at').inspect}"
    end
  end
end
