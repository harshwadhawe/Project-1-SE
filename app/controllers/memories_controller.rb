# frozen_string_literal: true

class MemoriesController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @memories = Memory.all
    @build_id = params[:build_id]
  end

  def show; end
end
