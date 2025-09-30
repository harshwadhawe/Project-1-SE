class MemoriesController < ApplicationController
  def index
    @memories = Memory.all
    @build_id = params[:build_id]
  end

  def show
  end
end
