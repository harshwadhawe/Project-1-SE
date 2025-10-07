# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Memory, type: :model do
  describe 'inheritance' do
    it 'inherits from Part' do
      expect(Memory.superclass).to eq(Part)
    end

    it 'creates with correct STI type' do
      memory = Memory.create!(brand: 'G.Skill', name: 'Trident Z5', price_cents: 15_000, wattage: 10)
      expect(memory.type).to eq('Memory')
      expect(memory).to be_a(Memory)
      expect(memory).to be_a(Part)
    end
  end

  describe 'basic functionality' do
    it 'creates valid Memory with required fields' do
      memory = Memory.create!(
        brand: 'Corsair',
        name: 'Vengeance LPX 32GB',
        price_cents: 12_000,
        wattage: 8
      )
      expect(memory).to be_persisted
      expect(memory.brand).to eq('Corsair')
      expect(memory.name).to eq('Vengeance LPX 32GB')
    end

    it 'inherits Part validations' do
      memory = Memory.new(brand: '', name: '')
      expect(memory).not_to be_valid
      expect(memory.errors[:brand]).to include("can't be blank")
      expect(memory.errors[:name]).to include("can't be blank")
    end
  end
end
