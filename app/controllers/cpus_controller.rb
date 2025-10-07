# frozen_string_literal: true

class CpusController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @cpus = Cpu.all
    @build_id = params[:build_id]
  end

  def show; end
end
