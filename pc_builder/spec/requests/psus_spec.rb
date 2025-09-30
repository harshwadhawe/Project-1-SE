require 'rails_helper'

RSpec.describe "Psus", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/psus/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/psus/show"
      expect(response).to have_http_status(:success)
    end
  end

end
