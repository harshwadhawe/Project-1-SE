require 'rails_helper'

RSpec.describe "PcCases", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/pc_cases/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/pc_cases/show"
      expect(response).to have_http_status(:success)
    end
  end

end
