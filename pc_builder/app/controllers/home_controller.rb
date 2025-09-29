class HomeController < ApplicationController
  def index
    @categories = {
      "Cpu"        => Cpu,
      "GPU"        => Gpu,
      "Motherboard"=> Motherboard,
      "Memory"     => Memory,
      "Storage"    => Storage,
      "Cooler"     => Cooler,
      "Case"       => PcCase,
      "PSU"        => Psu
    }

    # load a few parts from each category
    @sample_parts = {}
    @categories.each do |name, klass|
      @sample_parts[name] = klass.limit(3)
    end

    @recent_builds = Build.order(created_at: :desc).limit(3)
  end
end
