class StoragesController < ApplicationController
  def index
    @storages = Storage.all
    @build_id = params[:build_id]
  end

  def show
  end
end
