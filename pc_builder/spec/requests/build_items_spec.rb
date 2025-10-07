require 'rails_helper'

RSpec.describe "BuildItems", type: :request do
  # Setup data that is used across all tests
  let!(:user) { User.create!(name: "Test User", email: "test@example.com", password: "password") }
  let!(:build) { Build.create!(name: "Test Build", user: user) }
  let!(:cpu) { Cpu.create!(brand: "Test", name: "Test CPU", price_cents: 10000, wattage: 100) }
  let!(:gpu) { Gpu.create!(brand: "Test", name: "Test GPU", price_cents: 20000, wattage: 200) }

  describe "POST /create" do
    # This before block runs only for the tests inside this "POST /create" group
    before do
      post login_path, params: { email: user.email, password: "password" }
    end

    context "when adding a new type of part" do
      it "creates a new build_item and redirects to the build's show page" do
        expect {
          post build_build_items_path(build), params: { part_id: cpu.id }
        }.to change(BuildItem, :count).by(1)
        
        expect(response).to redirect_to(build_url(build))
        expect(flash[:notice]).to match(/was successfully added/)
      end
    end

    context "when replacing an existing type of part" do
      before do
        # We need to create the initial item inside this context
        build.build_items.create!(part: cpu)
      end
      
      it "updates the existing build_item instead of creating a new one" do
        another_cpu = Cpu.create!(brand: "Another", name: "Another CPU", price_cents: 15000, wattage: 120)
        
        expect {
          post build_build_items_path(build), params: { part_id: another_cpu.id }
        }.not_to change(BuildItem, :count)
        
        # After the request, we need to reload the build to see the changes
        build.reload
        expect(build.parts).to include(another_cpu)
        expect(build.parts).not_to include(cpu)
        expect(flash[:notice]).to match(/was replaced with/)
      end
    end
  end

  describe "DELETE /destroy" do
    let!(:build_item) { build.build_items.create!(part: gpu) }

    # This before block runs only for the tests inside this "DELETE /destroy" group
    before do
      post login_path, params: { email: user.email, password: "password" }
    end

    it "destroys the requested build_item" do
      expect {
        delete build_build_item_path(build, build_item)
      }.to change(BuildItem, :count).by(-1)
    end

    it "redirects to the build's show page" do
      delete build_build_item_path(build, build_item)
      expect(response).to redirect_to(build_url(build))
    end

    it "sets a success notice" do
      delete build_build_item_path(build, build_item)
      expect(flash[:notice]).to match(/was successfully removed/)
    end
  end
end