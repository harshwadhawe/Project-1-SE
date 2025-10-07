require 'rails_helper'

RSpec.describe "Memories", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/memories"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      memory = Memory.create!(brand: "Corsair", name: "Test RAM", model_number: "TEST-001", price_cents: 15000, wattage: 10)
      get "/memories/#{memory.id}"
      expect(response).to have_http_status(:success)
    end
  end
end
