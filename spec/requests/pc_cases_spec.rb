require 'rails_helper'

RSpec.describe "PcCases", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/pc_cases"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      pc_case = PcCase.create!(brand: "Fractal", name: "Test Case", model_number: "TEST-001", price_cents: 10000, wattage: 0)
      get "/pc_cases/#{pc_case.id}"
      expect(response).to have_http_status(:success)
    end
  end
end
