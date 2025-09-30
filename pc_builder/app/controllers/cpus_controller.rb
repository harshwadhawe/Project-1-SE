class CpusController < ApplicationController
  def index
    @cpus = Cpu.all
    @build_id = params[:build_id]
  end

  def show
  end
end
