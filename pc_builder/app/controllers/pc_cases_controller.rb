class PcCasesController < ApplicationController
    def index
    @cases = PcCase.all
    @build_id = params[:build_id]
  end

  def show
  end
end
