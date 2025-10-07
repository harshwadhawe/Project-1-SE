# frozen_string_literal: true

class GpusController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @gpus = Gpu.all
    @build_id = params[:build_id]
  end

  def show; end
end
