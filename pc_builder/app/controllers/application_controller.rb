class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :log_request_start
  before_action :authenticate_user!
  after_action :log_request_end
  around_action :log_performance

  rescue_from StandardError, with: :handle_standard_error
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing

  protected

  def current_user
    return @current_user if defined?(@current_user)
    
    @current_user = if jwt_token.present?
      User.decode_jwt_token(jwt_token)
    else
      nil
    end
    
    Rails.logger.debug "[AUTH] Current user: #{@current_user&.id || 'none'} (#{@current_user&.email})" if @current_user
    @current_user
  end
  helper_method :current_user

  def authenticate_user!
    unless current_user
      Rails.logger.warn "[AUTH] Unauthorized access attempt to #{request.fullpath}"
      
      respond_to do |format|
        format.html { 
          flash[:alert] = "Please log in to access this page"
          redirect_to login_path 
        }
        format.json { 
          render json: { error: 'Authentication required' }, status: :unauthorized 
        }
      end
    end
  end

  def jwt_token
    return @jwt_token if defined?(@jwt_token)

    signed = cookies.respond_to?(:signed) ? cookies.signed : nil
    @jwt_token = signed && (signed[:jwt_token] || signed['jwt_token'])
  end

  private

  def log_request_start
    Rails.logger.info "[REQUEST START] #{request.method} #{request.fullpath} - IP: #{request.remote_ip} - User-Agent: #{request.user_agent&.truncate(100)}"
    Rails.logger.info "[REQUEST PARAMS] #{sanitized_params}" unless params.empty?
    session_id_str = session.id.respond_to?(:to_s) ? session.id.to_s : session.id.inspect
    Rails.logger.info "[SESSION INFO] User ID: #{current_user&.id || 'guest'}, Session ID: #{session_id_str&.truncate(10)}"
  end

  def log_request_end
    Rails.logger.info "[REQUEST END] #{request.method} #{request.fullpath} - Status: #{response.status} - Content-Type: #{response.content_type}"
  end

  def log_performance
    start_time = Time.current
    Rails.logger.info "[PERFORMANCE START] Action: #{params[:controller]}##{params[:action]}"
    
    yield
    
    duration = (Time.current - start_time) * 1000
    Rails.logger.info "[PERFORMANCE END] Action: #{params[:controller]}##{params[:action]} - Duration: #{duration.round(2)}ms"
    
    if duration > 1000 # Log slow requests (> 1 second)
      Rails.logger.warn "[SLOW REQUEST] #{params[:controller]}##{params[:action]} took #{duration.round(2)}ms"
    end
  end

  def handle_standard_error(exception)
    Rails.logger.error "[ERROR] #{exception.class}: #{exception.message}"
    Rails.logger.error "[ERROR BACKTRACE] #{exception.backtrace&.first(10)&.join('\n')}"
    Rails.logger.error "[ERROR CONTEXT] Controller: #{params[:controller]}, Action: #{params[:action]}, Params: #{sanitized_params}"
    
    respond_to do |format|
      format.html { render file: 'public/500.html', status: 500 }
      format.json { render json: { error: 'Internal server error' }, status: 500 }
    end
  end

  def handle_record_not_found(exception)
    Rails.logger.warn "[RECORD NOT FOUND] #{exception.class}: #{exception.message} - Params: #{sanitized_params}"
    
    respond_to do |format|
      format.html { render file: 'public/404.html', status: 404 }
      format.json { render json: { error: 'Record not found' }, status: 404 }
    end
  end

  def handle_parameter_missing(exception)
    Rails.logger.warn "[PARAMETER MISSING] #{exception.class}: #{exception.message} - Params: #{sanitized_params}"
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, alert: 'Required parameter missing') }
      format.json { render json: { error: exception.message }, status: 400 }
    end
  end

  def sanitized_params
    # Remove sensitive information from logs
    filtered_params = params.except(:password, :password_confirmation, :authenticity_token)
    filtered_params.to_unsafe_h.inspect.truncate(500)
  end
end
