class PsusController < ApplicationController
    def index
    @power_supplies = Psu.all
    @build_id = params[:build_id]
  end

  def show
  end
end
