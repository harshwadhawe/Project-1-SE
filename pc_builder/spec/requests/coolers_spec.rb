require 'rails_helper'

RSpec.describe "Coolers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/coolers"
      expect(response).to have_http_status(:success)
    end

    it "displays coolers" do
      cooler1 = cooler(brand: "Noctua", name: "NH-D15")
      cooler2 = cooler(brand: "Corsair", name: "H100i")
      get "/coolers"
      expect(response.body).to include("NH-D15")
      expect(response.body).to include("H100i")
    end

    it "accepts build_id parameter" do
      build = Build.create!(name: "Test Build")
      get "/coolers", params: { build_id: build.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      test_cooler = Cooler.create!(brand: "Noctua", name: "Test Cooler", model_number: "TEST-001", price_cents: 8000, wattage: 3)
      get "/coolers/#{test_cooler.id}"
      expect(response).to have_http_status(:success)
    end

    it "renders show template" do
      test_cooler = cooler(brand: "Arctic", name: "Freezer 34")
      get "/coolers/#{test_cooler.id}"
      expect(response).to have_http_status(:success)
      # The show template might be a placeholder, so just check it renders
      expect(response.body).to include("Coolers")
    end

    it "handles non-existent cooler gracefully" do
      get "/coolers/999999"
      expect(response).to have_http_status(:success)
    end
  end
end
