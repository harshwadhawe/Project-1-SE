class MotherboardsController < ApplicationController
  def index
    @motherboards = Motherboard.all
    @build_id = params[:build_id]
  end

  def show
  end
end
