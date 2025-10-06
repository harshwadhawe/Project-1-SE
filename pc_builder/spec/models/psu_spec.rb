require "rails_helper"

RSpec.describe Psu, type: :model do
  describe 'inheritance' do
    it 'inherits from Part' do
      expect(Psu.superclass).to eq(Part)
    end

    it 'creates with correct STI type' do
      psu = Psu.create!(brand: "Corsair", name: "RM850x", price_cents: 14000, wattage: 0)
      expect(psu.type).to eq("Psu")
      expect(psu).to be_a(Psu)
      expect(psu).to be_a(Part)
    end
  end

  describe 'basic functionality' do
    it 'creates valid PSU with required fields' do
      psu = Psu.create!(
        brand: "EVGA",
        name: "SuperNOVA 750W",
        price_cents: 12000,
        wattage: 0
      )
      expect(psu).to be_persisted
      expect(psu.brand).to eq("EVGA")
      expect(psu.name).to eq("SuperNOVA 750W")
    end

    it 'inherits Part validations' do
      psu = Psu.new(brand: "", name: "")
      expect(psu).not_to be_valid
      expect(psu.errors[:brand]).to include("can't be blank")
      expect(psu.errors[:name]).to include("can't be blank")
    end
  end
end