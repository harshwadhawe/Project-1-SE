class UsersController < ApplicationController
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

  private

  def log_users_action
    Rails.logger.info "[USERS CONTROLLER] Action: #{action_name}, User: #{current_user&.id || 'guest'}"
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
