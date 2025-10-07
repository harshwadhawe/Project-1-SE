# frozen_string_literal: true

class PcCasesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @pc_cases = PcCase.all
    @build_id = params[:build_id]
  end

  def show; end
end
