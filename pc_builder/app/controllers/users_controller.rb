class UsersController < ApplicationController
  # Skip authentication for signup actions
  skip_before_action :authenticate_user!, only: [:new, :create]
  # Skip authentication for signup actions
  skip_before_action :authenticate_user!, only: [:new, :create]
  before_action :log_users_action

  def index
    Rails.logger.info "[USERS INDEX] Loading users list for user: #{current_user&.id || 'guest'}"
    @users = User.order(:name)
    Rails.logger.info "[USERS INDEX] Found #{@users.count} users"
    
    # Log user statistics
    if @users.respond_to?(:joins)
      users_with_builds = @users.joins(:builds).distinct.count
      Rails.logger.info "[USERS INDEX] #{users_with_builds} users have builds"
    end
  end

  def show
    Rails.logger.info "[USERS SHOW] Loading user ID: #{params[:id]} for requesting user: #{current_user&.id || 'guest'}"
    @user = User.find(params[:id])
    Rails.logger.info "[USERS SHOW] Successfully loaded user: #{@user.name} (#{@user.email})"
    
    # Log user build count
    build_count = @user.builds.count
    Rails.logger.info "[USERS SHOW] User has #{build_count} builds"
  end

  def new
    @user = User.new
    Rails.logger.info "[USERS NEW] Rendering signup form"
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      # Auto-login after successful registration
      token = @user.generate_jwt_token
      
      cookies.signed[:jwt_token] = {
        value: token,
        expires: 24.hours.from_now,
        httponly: true,
        secure: Rails.env.production?
      }
      
      Rails.logger.info "[SIGNUP SUCCESS] User #{@user.id} (#{@user.email}) created and logged in"
      flash[:success] = "Welcome to PC Builder, #{@user.name}!"
      redirect_to root_path
    else
      Rails.logger.warn "[SIGNUP FAILED] User creation failed: #{@user.errors.full_messages.join(', ')}"
      flash.now[:error] = "Please fix the errors below"
      render :new, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def log_users_action
    Rails.logger.info "[USERS CONTROLLER] Action: #{action_name}, User: #{current_user&.id || 'guest'}"
  end
end
