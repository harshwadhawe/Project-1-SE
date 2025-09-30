require 'rails_helper'

RSpec.describe "Coolers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/coolers"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      cooler = Cooler.create!(brand: "Noctua", name: "Test Cooler", model_number: "TEST-001", price_cents: 8000, wattage: 3)
      get "/coolers/#{cooler.id}"
      expect(response).to have_http_status(:success)
    end
  end
end
