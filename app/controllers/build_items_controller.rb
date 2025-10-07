# frozen_string_literal: true

class BuildItemsController < ApplicationController
  def create
    @build = Build.find(params[:build_id])
    @part = Part.find(params[:part_id])
    @clas = params[:part_class]
    Rails.logger.info @clas.to_s
    Rails.logger.info 'add'
    existing_item = @build.build_items.joins(:part).find_by(parts: { type: @part.type })

    if existing_item
      old_part_name = existing_item.part.name
      existing_item.update(part: @part)
      flash[:notice] = "#{old_part_name} was replaced with #{@part.name}."
    else
      @build.build_items.create(part: @part)
      flash[:notice] = "#{@part.name} was successfully added to your build."
    end

    @sample_parts = {}
    @build.parts.each do |part|
      @sample_parts[part.class.name] = part
    end

    redirect_to build_path(@build)
  end
end
