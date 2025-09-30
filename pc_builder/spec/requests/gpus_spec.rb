require 'rails_helper'

RSpec.describe "Gpus", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/gpus/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/gpus/show"
      expect(response).to have_http_status(:success)
    end
  end

end
