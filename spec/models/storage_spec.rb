require "rails_helper"

RSpec.describe Storage, type: :model do
  describe 'inheritance' do
    it 'inherits from Part' do
      expect(Storage.superclass).to eq(Part)
    end

    it 'creates with correct STI type' do
      storage = Storage.create!(brand: "Samsung", name: "990 Pro 2TB", price_cents: 22000, wattage: 7)
      expect(storage.type).to eq("Storage")
      expect(storage).to be_a(Storage)
      expect(storage).to be_a(Part)
    end
  end

  describe 'basic functionality' do
    it 'creates valid Storage with required fields' do
      storage = Storage.create!(
        brand: "WD",
        name: "Black SN850X 1TB",
        price_cents: 15000,
        wattage: 6
      )
      expect(storage).to be_persisted
      expect(storage.brand).to eq("WD")
      expect(storage.name).to eq("Black SN850X 1TB")
    end

    it 'inherits Part validations' do
      storage = Storage.new(brand: "", name: "")
      expect(storage).not_to be_valid
      expect(storage.errors[:brand]).to include("can't be blank")
      expect(storage.errors[:name]).to include("can't be blank")
    end
  end
end