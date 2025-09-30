require 'rails_helper'

RSpec.describe "Cpus", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/cpus/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/cpus/show"
      expect(response).to have_http_status(:success)
    end
  end

end
