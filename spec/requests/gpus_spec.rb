require 'rails_helper'

RSpec.describe "Gpus", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/gpus"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      gpu = Gpu.create!(brand: "NVIDIA", name: "Test GPU", model_number: "TEST-001", price_cents: 50000, wattage: 200)
      get "/gpus/#{gpu.id}"
      expect(response).to have_http_status(:success)
    end
  end
end
