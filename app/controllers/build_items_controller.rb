class BuildItemsController < ApplicationController
  def create
    @build = Build.find(params[:build_id])
    @part = Part.find(params[:part_id])
    @clas = (params[:part_class])
    Rails.logger.info "#{@clas}"
    Rails.logger.info "add"
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

<<<<<<< HEAD:pc_builder/app/controllers/build_items_controller.rb
  # ADDED: New method to handle removing a part from a build
=======
>>>>>>> change-repo-structure:app/controllers/build_items_controller.rb
  def destroy
    @build = Build.find(params[:build_id])
    @build_item = @build.build_items.find(params[:id])
    part_name = @build_item.part.name
    
    if @build_item.destroy
      flash[:notice] = "#{part_name} was successfully removed from your build."
    else
      flash[:alert] = "Failed to remove #{part_name}."
    end

    redirect_to build_path(@build), status: :see_other
  end
end