class SessionsController < ApplicationController
  # Skip authentication for login and logout actions
  skip_before_action :authenticate_user!, only: [:new, :create, :destroy]
  
  def new
    # Login form
    Rails.logger.info "[SESSIONS] Rendering login form"
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    
    if user&.authenticate(params[:session][:password])
      token = user.generate_jwt_token
      
      # Set JWT token in cookie
      cookies.signed[:jwt_token] = {
        value: token,
        expires: 24.hours.from_now,
        httponly: true,
        secure: Rails.env.production?
      }
      
      Rails.logger.info "[LOGIN SUCCESS] User #{user.id} (#{user.email}) logged in successfully"
      flash[:success] = "Welcome back, #{user.name}!"
      redirect_to root_path
    else
      Rails.logger.warn "[LOGIN FAILED] Invalid credentials for email: #{params[:session][:email]}"
      flash.now[:error] = "Invalid email or password"
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    if current_user
      current_user_id = current_user.id
      current_user_email = current_user.email
      current_user_name = current_user.name
      
      # Clear JWT token cookie
      cookies.delete(:jwt_token)
      
      Rails.logger.info "[LOGOUT] User #{current_user_id} (#{current_user_email}) logged out successfully"
      flash[:success] = "Goodbye #{current_user_name}! You have been logged out successfully."
    else
      Rails.logger.warn "[LOGOUT] Logout attempt when no user was logged in"
      flash[:notice] = "You were already logged out."
    end
    
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render json: { success: true, message: "Logged out successfully" } }
    end
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end