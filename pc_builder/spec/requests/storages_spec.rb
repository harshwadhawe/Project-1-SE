require 'rails_helper'

RSpec.describe "Storages", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/storages"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      storage = Storage.create!(brand: "Samsung", name: "Test SSD", model_number: "TEST-001", price_cents: 12000, wattage: 5)
      get "/storages/#{storage.id}"
      expect(response).to have_http_status(:success)
    end
  end
end
