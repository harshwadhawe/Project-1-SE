require 'rails_helper'

RSpec.describe "Storages", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/storages/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/storages/show"
      expect(response).to have_http_status(:success)
    end
  end

end
