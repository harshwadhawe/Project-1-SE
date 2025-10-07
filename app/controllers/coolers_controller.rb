# frozen_string_literal: true

class CoolersController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @coolers = Cooler.all
    @build_id = params[:build_id]
  end

  def show; end
end
