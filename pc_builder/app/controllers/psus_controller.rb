class PsusController < ApplicationController
  skip_before_action :authenticate_user!
  
  def index
    @psus = Psu.all
    @build_id = params[:build_id]
  end

  def show
  end
end