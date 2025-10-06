require 'rails_helper'

RSpec.describe "Parts", type: :request do
  # Create test parts for each category
  before do
    @cpu = Cpu.create!(name: "AMD Ryzen 7", brand: "AMD", price_cents: 29900, wattage: 65)
    @gpu = Gpu.create!(name: "RTX 4070", brand: "NVIDIA", price_cents: 59900, wattage: 200)
    @motherboard = Motherboard.create!(name: "ASUS B550", brand: "ASUS", price_cents: 14900, wattage: 50)
    @memory = Memory.create!(name: "Corsair 16GB", brand: "Corsair", price_cents: 7900, wattage: 10)
    @storage = Storage.create!(name: "Samsung SSD", brand: "Samsung", price_cents: 9900, wattage: 5)
    @cooler = Cooler.create!(name: "Noctua Air", brand: "Noctua", price_cents: 8900, wattage: 5)
    @pc_case = PcCase.create!(name: "NZXT H7", brand: "NZXT", price_cents: 12900, wattage: 0)
    @psu = Psu.create!(name: "Corsair 750W", brand: "Corsair", price_cents: 11900, wattage: 750)
  end

  describe "GET /parts (index)" do
    it "returns successful response" do
      get "/parts"
      expect(response).to have_http_status(:success)
    end

    it "loads all parts by default" do
      get "/parts"
      expect(response.body).to include("AMD Ryzen 7")
      expect(response.body).to include("RTX 4070")
      expect(response.body).to include("ASUS B550")
    end

    it "filters parts by category" do
      get "/parts", params: { category: "CPU" }
      expect(response.body).to include("AMD Ryzen 7")
      expect(response).to have_http_status(:success)
    end

    it "filters parts by brand" do
      get "/parts", params: { brand: "AMD" }
      expect(response.body).to include("AMD Ryzen 7")
      expect(response).to have_http_status(:success)
    end

    it "handles invalid category gracefully" do
      get "/parts", params: { category: "InvalidCategory" }
      expect(response).to have_http_status(:success)
    end

    it "handles invalid brand gracefully" do
      get "/parts", params: { brand: "InvalidBrand" }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /parts/:id (show)" do
    it "returns successful response for existing part" do
      get "/parts/#{@cpu.id}"
      expect(response).to have_http_status(:success)
    end

    it "displays part information" do
      get "/parts/#{@cpu.id}"
      expect(response.body).to include("AMD Ryzen 7")
      expect(response.body).to include("AMD")
    end

    it "works for all part types" do
      parts = [@cpu, @gpu, @motherboard, @memory, @storage, @cooler, @pc_case, @psu]
      
      parts.each do |part|
        get "/parts/#{part.id}"
        expect(response).to have_http_status(:success)
        expect(response.body).to include(part.name)
      end
    end
  end

  describe "authentication behavior" do
    it "allows access without authentication" do
      get "/parts"
      expect(response).to have_http_status(:success)
    end
  end

  describe "filtering functionality" do
    before do
      # Create more diverse parts for better filtering tests
      @intel_cpu = Cpu.create!(name: "Intel i5", brand: "Intel", price_cents: 19900, wattage: 65)
      @amd_gpu = Gpu.create!(name: "AMD RX 7900", brand: "AMD", price_cents: 69900, wattage: 250)
    end

    it "combines category and brand filters" do
      get "/parts", params: { category: "CPU", brand: "Intel" }
      expect(response).to have_http_status(:success)
    end

    it "empty filters return all parts" do
      get "/parts", params: { category: "", brand: "" }
      expect(response).to have_http_status(:success)
    end
  end

  describe "performance considerations" do
    before do
      # Create many parts to test performance
      25.times do |i|
        Cpu.create!(name: "CPU #{i}", brand: "TestBrand#{i % 5}", price_cents: (100 + i) * 100, wattage: 65)
      end
    end

    it "responds efficiently with many parts" do
      start_time = Time.current
      get "/parts"
      end_time = Time.current
      
      expect(response).to have_http_status(:success)
      expect(end_time - start_time).to be < 2.seconds
    end

    it "filters efficiently" do
      start_time = Time.current
      get "/parts", params: { category: "CPU", brand: "TestBrand1" }
      end_time = Time.current
      
      expect(response).to have_http_status(:success)
      expect(end_time - start_time).to be < 1.second
    end
  end

  describe "edge cases" do
    it "handles parts with nil prices" do
      part_with_nil_price = Cpu.create!(name: "Free CPU", brand: "FreeBrand", price_cents: nil, wattage: 65)
      
      get "/parts"
      expect(response).to have_http_status(:success)
    end

    it "handles parts with zero wattage" do
      get "/parts/#{@pc_case.id}" # PC cases typically have 0 wattage
      expect(response).to have_http_status(:success)
      expect(response.body).to include("NZXT H7")
    end

    it "handles empty database gracefully" do
      Part.destroy_all
      
      get "/parts"
      expect(response).to have_http_status(:success)
    end
  end

  # JSON responses may not be implemented in all controllers
  # Focus on HTML response testing for coverage
end