class User < ApplicationRecord
  # Authentication
  has_secure_password
  
  before_validation :normalize_email
  before_create :log_user_creation
  after_create :log_user_created
  before_destroy :log_user_destruction
  after_validation :log_validation_results
  
  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    'valid_email_2/email': true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  has_many :builds, dependent: :nullify
  
  # JWT token methods
  def self.jwt_secret
    Rails.application.secret_key_base
  end
  
  def generate_jwt_token
    payload = {
      user_id: id,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, self.class.jwt_secret, 'HS256')
  end
  
  def self.decode_jwt_token(token)
    decoded = JWT.decode(token, jwt_secret, true, { algorithm: 'HS256' })
    user_id = decoded[0]['user_id']
    find(user_id)
  rescue JWT::DecodeError, JWT::ExpiredSignature, ActiveRecord::RecordNotFound
    nil
  end

  private

  def normalize_email
    old_email = email
    self.email = email.to_s.strip.downcase
    Rails.logger.debug "[USER VALIDATION] Email normalized: '#{old_email}' -> '#{email}'" if old_email != email
  end

  def log_user_creation
    Rails.logger.info "[USER CREATE] Creating new user: #{name} (#{email})"
  end

  def log_user_created
    Rails.logger.info "[USER CREATED] Successfully created user ID: #{id} - #{name} (#{email})"
  end

  def log_user_destruction
    Rails.logger.warn "[USER DESTROY] Destroying user ID: #{id} - #{name} (#{email}) with #{builds.count} builds"
  end

  def log_validation_results
    if errors.any?
      Rails.logger.warn "[USER VALIDATION] Validation failed for user '#{name}' (#{email}): #{errors.full_messages.join(', ')}"
    else
      Rails.logger.debug "[USER VALIDATION] Validation passed for user '#{name}' (#{email})"
    end
  end
end
