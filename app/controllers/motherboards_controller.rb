# frozen_string_literal: true

class MotherboardsController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @motherboards = Motherboard.all
    @build_id = params[:build_id]
  end

  def show; end
end
