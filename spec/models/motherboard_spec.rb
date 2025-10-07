# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Motherboard, type: :model do
  describe 'inheritance' do
    it 'inherits from Part' do
      expect(Motherboard.superclass).to eq(Part)
    end

    it 'creates with correct STI type' do
      motherboard = Motherboard.create!(brand: 'ASUS', name: 'ROG Strix B650E', price_cents: 25_000, wattage: 30)
      expect(motherboard.type).to eq('Motherboard')
      expect(motherboard).to be_a(Motherboard)
      expect(motherboard).to be_a(Part)
    end
  end

  describe 'basic functionality' do
    it 'creates valid Motherboard with required fields' do
      motherboard = Motherboard.create!(
        brand: 'MSI',
        name: 'B550 Gaming Plus',
        price_cents: 18_000,
        wattage: 25
      )
      expect(motherboard).to be_persisted
      expect(motherboard.brand).to eq('MSI')
      expect(motherboard.name).to eq('B550 Gaming Plus')
    end

    it 'inherits Part validations' do
      motherboard = Motherboard.new(brand: '', name: '')
      expect(motherboard).not_to be_valid
      expect(motherboard.errors[:brand]).to include("can't be blank")
      expect(motherboard.errors[:name]).to include("can't be blank")
    end
  end
end
