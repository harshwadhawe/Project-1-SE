require "rails_helper"

RSpec.describe Gpu, type: :model do
  describe 'inheritance' do
    it 'inherits from Part' do
      expect(Gpu.superclass).to eq(Part)
    end

    it 'creates with correct STI type' do
      gpu = Gpu.create!(brand: "NVIDIA", name: "RTX 4080", price_cents: 120000, wattage: 320)
      expect(gpu.type).to eq("Gpu")
      expect(gpu).to be_a(Gpu)
      expect(gpu).to be_a(Part)
    end
  end

  describe 'basic functionality' do
    it 'creates valid GPU with required fields' do
      gpu = Gpu.create!(
        brand: "AMD",
        name: "RX 7800 XT",
        price_cents: 50000,
        wattage: 263
      )
      expect(gpu).to be_persisted
      expect(gpu.brand).to eq("AMD")
      expect(gpu.name).to eq("RX 7800 XT")
    end

    it 'inherits Part validations' do
      gpu = Gpu.new(brand: "", name: "")
      expect(gpu).not_to be_valid
      expect(gpu.errors[:brand]).to include("can't be blank")
      expect(gpu.errors[:name]).to include("can't be blank")
    end

    it 'can be found as Part' do
      gpu = Gpu.create!(brand: "NVIDIA", name: "RTX 4090", price_cents: 160000, wattage: 450)
      found_part = Part.find(gpu.id)
      expect(found_part).to eq(gpu)
      expect(found_part).to be_a(Gpu)
    end
  end
end