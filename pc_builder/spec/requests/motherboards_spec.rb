require 'rails_helper'

RSpec.describe "Motherboards", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/motherboards/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/motherboards/show"
      expect(response).to have_http_status(:success)
    end
  end

end
