class GpusController < ApplicationController
  def index
    @gpus = Gpu.all
    @build_id = params[:build_id]
  end

  def show
  end
end
