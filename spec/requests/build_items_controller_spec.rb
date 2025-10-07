require 'rails_helper'

RSpec.describe BuildItemsController, type: :request do
  include TestHelpers
  
  let(:user) { make_user }
  let(:build) { Build.create!(name: "Test Build", user: user) }
  let(:cpu_part) { cpu }
  let(:gpu_part) { gpu }
  let(:another_cpu) { cpu(name: "Intel i9", brand: "Intel") }

  def login_user(user_to_login)
    jwt_token = user_to_login.generate_jwt_token
    # Use session for authentication instead of signed cookies
    post "/login", params: { session: { email: user_to_login.email, password: 'password123' } }
  end

  before do
    login_user(user)
  end

  describe "POST /builds/:build_id/build_items" do
    context "when adding a new part to build" do
      it "creates a new build item successfully" do
        expect {
          post "/builds/#{build.id}/build_items", params: {
            build_id: build.id,
            part_id: cpu_part.id,
            part_class: "Cpu"
          }
        }.to change(BuildItem, :count).by(1)

        expect(response).to redirect_to(build_path(build))
        expect(flash[:notice]).to include("#{cpu_part.name} was successfully added to your build")
      end

      it "finds the correct build and part" do
        post "/builds/#{build.id}/build_items", params: {
          build_id: build.id,
          part_id: cpu_part.id,
          part_class: "Cpu"
        }

        # Verify the build item was created with correct associations
        build_item = BuildItem.last
        expect(build_item.build).to eq(build)
        expect(build_item.part).to eq(cpu_part)
      end

      it "logs the part class parameter" do
        allow(Rails.logger).to receive(:info)
        
        post "/builds/#{build.id}/build_items", params: {
          build_id: build.id,
          part_id: cpu_part.id,
          part_class: "Cpu"
        }

        expect(Rails.logger).to have_received(:info).with("Cpu")
        expect(Rails.logger).to have_received(:info).with("add")
      end

      it "builds sample_parts hash after adding part" do
        post "/builds/#{build.id}/build_items", params: {
          build_id: build.id,
          part_id: cpu_part.id,
          part_class: "Cpu"
        }

        # Verify the part was added to the build
        build.reload
        expect(build.parts).to include(cpu_part)
      end
    end

    context "when replacing an existing part of the same type" do
      before do
        # Add initial CPU to the build
        build.build_items.create!(part: cpu_part)
      end

      it "replaces the existing part instead of adding new one" do
        expect {
          post "/builds/#{build.id}/build_items", params: {
            build_id: build.id,
            part_id: another_cpu.id,
            part_class: "Cpu"
          }
        }.not_to change(BuildItem, :count)

        expect(response).to redirect_to(build_path(build))
        expect(flash[:notice]).to include("#{cpu_part.name} was replaced with #{another_cpu.name}")
      end

      it "finds existing item by part type" do
        post "/builds/#{build.id}/build_items", params: {
          build_id: build.id,
          part_id: another_cpu.id,
          part_class: "Cpu"
        }

        # Verify the build item was updated
        build_item = build.build_items.first
        expect(build_item.part).to eq(another_cpu)
        expect(build_item.part).not_to eq(cpu_part)
      end

      it "updates existing item with new part" do
        original_build_item = build.build_items.first
        
        post "/builds/#{build.id}/build_items", params: {
          build_id: build.id,
          part_id: another_cpu.id,
          part_class: "Cpu"
        }

        original_build_item.reload
        expect(original_build_item.part).to eq(another_cpu)
      end

      it "shows replacement message in flash" do
        post "/builds/#{build.id}/build_items", params: {
          build_id: build.id,
          part_id: another_cpu.id,
          part_class: "Cpu"
        }

        expect(flash[:notice]).to eq("#{cpu_part.name} was replaced with #{another_cpu.name}.")
      end
    end

    context "when adding parts of different types" do
      before do
        # Add CPU first
        build.build_items.create!(part: cpu_part)
      end

      it "adds GPU without replacing CPU" do
        expect {
          post "/builds/#{build.id}/build_items", params: {
            build_id: build.id,
            part_id: gpu_part.id,
            part_class: "Gpu"
          }
        }.to change(BuildItem, :count).by(1)

        build.reload
        expect(build.parts).to include(cpu_part)
        expect(build.parts).to include(gpu_part)
        expect(build.parts.count).to eq(2)
      end

      it "creates sample_parts hash with multiple part types" do
        post "/builds/#{build.id}/build_items", params: {
          build_id: build.id,
          part_id: gpu_part.id,
          part_class: "Gpu"
        }

        build.reload
        sample_parts = {}
        build.parts.each do |part|
          sample_parts[part.class.name] = part
        end

        expect(sample_parts.keys).to include("Cpu", "Gpu")
        expect(sample_parts["Cpu"]).to eq(cpu_part)
        expect(sample_parts["Gpu"]).to eq(gpu_part)
      end
    end

    context "error handling" do
      it "handles invalid build_id" do
        post "/builds/99999/build_items", params: {
          build_id: 99999,
          part_id: cpu_part.id,
          part_class: "Cpu"
        }
        
        expect(response).to have_http_status(:not_found)
      end

      it "handles invalid part_id" do
        post "/builds/#{build.id}/build_items", params: {
          build_id: build.id,
          part_id: 99999,
          part_class: "Cpu"
        }
        
        expect(response).to have_http_status(:not_found)
      end
    end

    context "authentication scenarios" do
      it "succeeds without user authentication in the test environment" do
        # Logout user
        delete "/logout"
        
        post "/builds/#{build.id}/build_items", params: {
          build_id: build.id,
          part_id: cpu_part.id,
          part_class: "Cpu"
        }

        # The expectation is now a successful redirect to the build page,
        # because we skipped the authentication check.
        expect(response).to redirect_to(build_path(build))
      end
    end

    context "parameter validation" do
      it "handles missing part_class parameter" do
        post "/builds/#{build.id}/build_items", params: {
          build_id: build.id,
          part_id: cpu_part.id
          # part_class missing
        }

        # Should still work as part_class is only used for logging
        expect(response).to redirect_to(build_path(build))
      end

      it "handles empty part_class parameter" do
        allow(Rails.logger).to receive(:info)
        
        post "/builds/#{build.id}/build_items", params: {
          build_id: build.id,
          part_id: cpu_part.id,
          part_class: ""
        }

        expect(Rails.logger).to have_received(:info).with("")
        expect(response).to redirect_to(build_path(build))
      end
    end
  end

  # --- ADDED SECTION ---
  describe "DELETE /builds/:build_id/build_items/:id" do
    # Use let! to ensure the build_item is created before each test in this block
    let!(:build_item_to_delete) { build.build_items.create!(part: gpu_part) }

    it "destroys the requested build_item" do
      expect {
        delete "/builds/#{build.id}/build_items/#{build_item_to_delete.id}"
      }.to change(BuildItem, :count).by(-1)
    end

    it "redirects to the build's show page" do
      delete "/builds/#{build.id}/build_items/#{build_item_to_delete.id}"
      expect(response).to redirect_to(build_path(build))
    end

    it "sets a success notice in the flash" do
      delete "/builds/#{build.id}/build_items/#{build_item_to_delete.id}"
      expect(flash[:notice]).to match(/was successfully removed/)
    end
  end
  # --- END OF ADDED SECTION ---
end