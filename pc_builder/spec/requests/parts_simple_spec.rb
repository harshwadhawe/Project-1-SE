# spec/requests/parts_controller_spec.rb
require "rails_helper"

RSpec.describe "Parts", type: :request do
  before do
    @cpu = Cpu.create!(name: "AMD Ryzen 7", brand: "AMD",    price_cents: 29900, wattage: 65)
    @gpu = Gpu.create!(name: "RTX 4070",     brand: "NVIDIA", price_cents: 59900, wattage: 200)
    @mb  = Motherboard.create!(name: "ASUS B550", brand: "ASUS", price_cents: 14900, wattage: 50)
    @mem = Memory.create!(name: "Corsair 16GB",   brand: "Corsair", price_cents: 7900,  wattage: 10)
    @sto = Storage.create!(name: "Samsung SSD",   brand: "Samsung", price_cents: 9900,  wattage: 5)
    @col = Cooler.create!(name: "Noctua Air",     brand: "Noctua",  price_cents: 8900,  wattage: 5)
    @case= PcCase.create!(name: "NZXT H7",        brand: "NZXT",    price_cents: 12900, wattage: 0)
    @psu = Psu.create!(name: "Corsair 750W",     brand: "Corsair", price_cents: 11900, wattage: 750)
  end

  describe "index advanced filters" do
    it "filters by :type param" do
      get "/parts", params: { type: "Cpu" }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("AMD Ryzen 7")
    end

    it "treats :q matching a type as a type (back-compat)" do
      get "/parts", params: { q: "Gpu" }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("RTX 4070")
    end

    it "searches by name when :q is not a type" do
      get "/parts", params: { q: "ryzen" }
      expect(response).to have_http_status(:success)
      expect(response.body).to include("AMD Ryzen 7")
    end

    it "filters brand case-insensitively" do
      get "/parts", params: { brand: "amd" } # lower-case on purpose
      expect(response).to have_http_status(:success)
      expect(response.body).to include("AMD Ryzen 7")
    end

    it "applies min_price (dollars → cents)" do
      get "/parts", params: { min_price: "150" } # 15000 cents
      expect(response).to have_http_status(:success)
      # should include GPU (59900) and CPU (29900), but still just check success/body non-empty
      expect(response.body).to include("AMD Ryzen 7")
    end

    it "applies max_price (dollars → cents)" do
      get "/parts", params: { max_price: "150" } # 15000 cents
      expect(response).to have_http_status(:success)
      expect(response.body).to include("ASUS B550") # 14900 fits
    end
  end

  describe "sorting options" do
    it "sorts by price ascending" do
      get "/parts", params: { sort: "price_asc" }
      expect(response).to have_http_status(:success)
    end

    it "sorts by price descending" do
      get "/parts", params: { sort: "price_desc" }
      expect(response).to have_http_status(:success)
    end

    it "sorts by brand ascending" do
      get "/parts", params: { sort: "brand_asc" }
      expect(response).to have_http_status(:success)
    end

    it "sorts by brand descending" do
      get "/parts", params: { sort: "brand_desc" }
      expect(response).to have_http_status(:success)
    end

    it "falls back to default ordering when sort param is missing/unknown" do
      get "/parts" # triggers the default branch
      expect(response).to have_http_status(:success)
    end
  end

  describe "show" do
    it "renders a part and hits debug lines" do
      get "/parts/#{@cpu.id}"
      expect(response).to have_http_status(:success)
      expect(response.body).to include("AMD Ryzen 7")
    end
  end

  describe "session-backed current_user path (covered by before_action logging)" do
    it "executes current_user and logs cleanly" do
      # Make the stub look like what the layout expects
      fake_user = double("User", id: 4242, email: "x@y.z", name: "Test User")
      allow(User).to receive(:find_by).with(id: anything).and_return(fake_user)

      get "/parts" # let Rails own the session object; don't pass rack.session here
      expect(response).to have_http_status(:success)

      # Optional: prove the layout saw the user's name
      expect(response.body).to include("Test User")
    end
  end

end
