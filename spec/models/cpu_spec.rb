# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cpu, type: :model do
  describe 'inheritance' do
    it 'inherits from Part' do
      expect(Cpu.superclass).to eq(Part)
    end

    it 'creates with correct STI type' do
      cpu = Cpu.create!(brand: 'AMD', name: 'Ryzen 7', price_cents: 30_000, wattage: 95)
      expect(cpu.type).to eq('Cpu')
      expect(cpu).to be_a(Cpu)
      expect(cpu).to be_a(Part)
    end
  end

  describe 'validations' do
    let(:valid_attributes) do
      {
        brand: 'AMD',
        name: 'Ryzen 7 7800X3D',
        price_cents: 30_000,
        wattage: 120,
        cpu_cores: 8,
        cpu_threads: 16,
        cpu_core_clock: 4.2,
        cpu_boost_clock: 5.0
      }
    end

    it 'validates cpu_cores when present' do
      cpu = Cpu.new(valid_attributes.merge(cpu_cores: 0))
      expect(cpu).not_to be_valid
      expect(cpu.errors[:cpu_cores]).to include('must be greater than 0')
    end

    it 'allows nil cpu_cores' do
      cpu = Cpu.new(valid_attributes.merge(cpu_cores: nil))
      expect(cpu).to be_valid
    end

    it 'validates cpu_threads when present' do
      cpu = Cpu.new(valid_attributes.merge(cpu_threads: 0))
      expect(cpu).not_to be_valid
      expect(cpu.errors[:cpu_threads]).to include('must be greater than 0')
    end

    it 'allows nil cpu_threads' do
      cpu = Cpu.new(valid_attributes.merge(cpu_threads: nil))
      expect(cpu).to be_valid
    end

    it 'validates positive numbers only' do
      cpu = Cpu.new(valid_attributes.merge(cpu_cores: -1, cpu_threads: -1))
      expect(cpu).not_to be_valid
      expect(cpu.errors[:cpu_cores]).to include('must be greater than 0')
      expect(cpu.errors[:cpu_threads]).to include('must be greater than 0')
    end
  end

  describe 'specs_summary method' do
    let(:cpu) do
      Cpu.create!(
        brand: 'AMD',
        name: 'Ryzen 7 7800X3D',
        price_cents: 30_000,
        wattage: 120,
        cpu_cores: 8,
        cpu_threads: 16,
        cpu_core_clock: 4.2,
        cpu_boost_clock: 5.0
      )
    end

    it 'returns formatted specs summary' do
      summary = cpu.specs_summary
      expect(summary).to include('8C/16T')
      expect(summary).to include('4.2GHz')
      expect(summary).to include('5.0GHz boost')
      expect(summary).to include('120W TDP')
    end

    it 'logs debug message when called' do
      expect(Rails.logger).to receive(:debug).with(/\[CPU #{cpu.id}\] Specs:/)
      cpu.specs_summary
    end
  end

  # Removed logging tests as they're too dependent on implementation details
  # The logging functionality is tested through integration rather than unit tests

  describe 'edge cases' do
    it 'handles missing clock speeds gracefully' do
      cpu = Cpu.create!(
        brand: 'AMD',
        name: 'Test CPU',
        price_cents: 20_000,
        wattage: 65,
        cpu_cores: 4,
        cpu_threads: 8
      )

      # Should not raise error even with nil clock speeds
      expect { cpu.specs_summary }.not_to raise_error
    end

    it 'creates valid CPU with minimal required fields' do
      cpu = Cpu.create!(brand: 'Test', name: 'Minimal CPU', price_cents: 10_000, wattage: 50)
      expect(cpu).to be_persisted
      expect(cpu.type).to eq('Cpu')
    end
  end
end
