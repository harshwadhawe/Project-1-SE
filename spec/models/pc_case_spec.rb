require "rails_helper"

RSpec.describe PcCase, type: :model do
  describe 'inheritance' do
    it 'inherits from Part' do
      expect(PcCase.superclass).to eq(Part)
    end

    it 'creates with correct STI type' do
      pc_case = PcCase.create!(brand: "Fractal", name: "Meshify 2", price_cents: 17000, wattage: 0)
      expect(pc_case.type).to eq("PcCase")
      expect(pc_case).to be_a(PcCase)
      expect(pc_case).to be_a(Part)
    end
  end

  describe 'basic functionality' do
    it 'creates valid PcCase with required fields' do
      pc_case = PcCase.create!(
        brand: "Lian Li",
        name: "O11 Dynamic",
        price_cents: 15000,
        wattage: 0
      )
      expect(pc_case).to be_persisted
      expect(pc_case.brand).to eq("Lian Li")
      expect(pc_case.name).to eq("O11 Dynamic")
    end

    it 'inherits Part validations' do
      pc_case = PcCase.new(brand: "", name: "")
      expect(pc_case).not_to be_valid
      expect(pc_case.errors[:brand]).to include("can't be blank")
      expect(pc_case.errors[:name]).to include("can't be blank")
    end
  end

  describe 'Case alias' do
    it 'defines Case as an alias for PcCase' do
      expect(Case).to eq(PcCase)
    end

    it 'creates Case instances as PcCase' do
      case_instance = Case.create!(
        brand: "NZXT",
        name: "H510",
        price_cents: 8000,
        wattage: 0
      )
      expect(case_instance).to be_a(PcCase)
      expect(case_instance.type).to eq("PcCase")
    end

    it 'finds Case instances through PcCase' do
      pc_case = PcCase.create!(brand: "Cooler Master", name: "H500", price_cents: 9000, wattage: 0)
      found_case = Case.find(pc_case.id)
      expect(found_case).to eq(pc_case)
      expect(found_case).to be_a(PcCase)
    end

    it 'allows Case.all to work' do
      PcCase.create!(brand: "Phanteks", name: "P400A", price_cents: 11000, wattage: 0)
      PcCase.create!(brand: "be quiet!", name: "Pure Base 500", price_cents: 8500, wattage: 0)
      
      expect(Case.all.count).to eq(2)
      expect(Case.all).to all(be_a(PcCase))
    end
  end

  describe 'STI integration' do
    it 'can be found as Part' do
      pc_case = PcCase.create!(brand: "Fractal", name: "Define 7", price_cents: 16000, wattage: 0)
      found_part = Part.find(pc_case.id)
      expect(found_part).to eq(pc_case)
      expect(found_part).to be_a(PcCase)
    end

    it 'appears in Part.all' do
      initial_count = Part.count
      PcCase.create!(brand: "Corsair", name: "4000D", price_cents: 10500, wattage: 0)
      expect(Part.count).to eq(initial_count + 1)
    end
  end
end