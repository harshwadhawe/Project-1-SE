require 'rails_helper'

RSpec.describe "Coolers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/coolers/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/coolers/show"
      expect(response).to have_http_status(:success)
    end
  end

end
