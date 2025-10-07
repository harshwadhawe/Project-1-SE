# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cooler, type: :model do
  describe 'inheritance' do
    it 'inherits from Part' do
      expect(Cooler.superclass).to eq(Part)
    end

    it 'creates with correct STI type' do
      cooler = Cooler.create!(brand: 'Noctua', name: 'NH-D15', price_cents: 10_000, wattage: 0)
      expect(cooler.type).to eq('Cooler')
      expect(cooler).to be_a(Cooler)
      expect(cooler).to be_a(Part)
    end
  end

  describe 'basic functionality' do
    it 'creates valid Cooler with required fields' do
      cooler = Cooler.create!(
        brand: 'be quiet!',
        name: 'Dark Rock Pro 4',
        price_cents: 8500,
        wattage: 0
      )
      expect(cooler).to be_persisted
      expect(cooler.brand).to eq('be quiet!')
      expect(cooler.name).to eq('Dark Rock Pro 4')
    end

    it 'inherits Part validations' do
      cooler = Cooler.new(brand: '', name: '')
      expect(cooler).not_to be_valid
      expect(cooler.errors[:brand]).to include("can't be blank")
      expect(cooler.errors[:name]).to include("can't be blank")
    end
  end
end
