require 'rails_helper'

RSpec.describe "Builds", type: :request do
  let(:user) { User.create!(name: "Builder", email: "builder@example.com", password: "password123") }
  
  # Create test parts for builds
  let!(:cpu) { Cpu.create!(name: "Test CPU", brand: "TestBrand", price_cents: 30000, wattage: 95) }
  let!(:gpu) { Gpu.create!(name: "Test GPU", brand: "TestBrand", price_cents: 50000, wattage: 200) }

  describe "GET /builds (index)" do
    before do
      @build1 = Build.create!(name: "Gaming PC", user: user)
      @build2 = Build.create!(name: "Work PC")
    end

    it "returns successful response" do
      get "/builds"
      expect(response).to have_http_status(:success)
    end

    it "displays builds" do
      get "/builds"
      expect(response.body).to include("Gaming PC")
      expect(response.body).to include("Work PC")
    end
  end

  describe "GET /builds/:id (show)" do
    before do
      @build = Build.create!(name: "Test Build", user: user)
      @build.parts << cpu
    end

    it "returns successful response for existing build" do
      get "/builds/#{@build.id}"
      expect(response).to have_http_status(:success)
    end

    it "displays build information" do
      get "/builds/#{@build.id}"
      expect(response.body).to include("Test Build")
    end
  end

  describe "GET /builds/new" do
    it "returns successful response" do
      get "/builds/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /builds (create)" do
    let(:valid_build_params) { { build: { name: "My New Build" } } }
    let(:invalid_build_params) { { build: { name: "" } } }

    context "with valid parameters" do
      it "creates a new build" do
        expect {
          post "/builds", params: valid_build_params
        }.to change(Build, :count).by(1)
      end

      it "redirects after creation" do
        post "/builds", params: valid_build_params
        expect(response).to have_http_status(:found)
      end
    end

    context "with invalid parameters" do
      it "does not create a build" do
        expect {
          post "/builds", params: invalid_build_params
        }.not_to change(Build, :count)
      end

      it "returns error status" do
        post "/builds", params: invalid_build_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "authentication scenarios" do
    before do
      @build = Build.create!(name: "Test Build", user: user)
    end

    it "allows access to index without authentication" do
      get "/builds"
      expect(response).to have_http_status(:success)
    end

    it "allows access to show without authentication" do
      get "/builds/#{@build.id}"
      expect(response).to have_http_status(:success)
    end

    it "allows access to new without authentication" do
      get "/builds/new"
      expect(response).to have_http_status(:success)
    end

    it "allows build creation without authentication" do
      post "/builds", params: { build: { name: "Anonymous Build" } }
      expect(response).to have_http_status(:found)
    end
  end
end