class StoragesController < ApplicationController
  skip_before_action :authenticate_user!
  
  def index
    @storages = Storage.all
    @build_id = params[:build_id]
  end

  def show
  end
end
