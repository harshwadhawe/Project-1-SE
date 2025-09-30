class CoolersController < ApplicationController
  def index
    @coolers = Cooler.all
    @build_id = params[:build_id]
  end

  def show
  end
end
