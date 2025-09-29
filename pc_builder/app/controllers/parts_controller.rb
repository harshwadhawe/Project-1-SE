class PartsController < ApplicationController
  def index
    if params[:q].present?
      @parts = Part.where(type: params[:q]).order(:brand, :name)
    else
      @parts = Part.order(:type, :brand, :name)
    end
  end

  def show
    @part = Part.find(params[:id])
  end
end
