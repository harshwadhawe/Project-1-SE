# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Part, type: :model do
  it 'creates STI subclasses correctly' do
    p1 = cpu
    p2 = gpu
    expect(p1).to be_a(Cpu)
    expect(p2).to be_a(Gpu)
    expect(p1.type).to eq('Cpu')
    expect(p2.type).to eq('Gpu')
  end

  it 'requires brand and name' do
    expect { Part.create!(type: 'Cpu', brand: '', name: '') }.to raise_error(ActiveRecord::RecordInvalid)
  end
end

RSpec.describe Part, type: :model do
  let(:logger_double) { instance_double(Logger, info: true, warn: true, debug: true) }

  before do
    allow(Rails).to receive(:logger).and_return(logger_double)
  end

  let(:valid_cpu_attrs) do
    {
      type: 'Cpu',
      brand: 'AMD',
      name: 'Ryzen 5 5600',
      model_number: '100-100000065BOX',
      price_cents: 199_99,
      wattage: 65,
      cpu_cores: 6,
      cpu_threads: 12,
      cpu_core_clock: 3.5,
      cpu_boost_clock: 4.4
    }
  end

  def build_part(overrides = {})
    Part.new(valid_cpu_attrs.merge(overrides))
  end

  def create_part!(overrides = {})
    Part.create!(valid_cpu_attrs.merge(overrides))
  end

  # --- STI / schema sanity ---
  it 'creates STI subclasses correctly' do
    p1 = create_part!(type: 'Cpu')
    p2 = Part.create!(
      type: 'Gpu',
      brand: 'NVIDIA',
      name: 'GeForce RTX 4060',
      model_number: '900-1G141-2540-000',
      price_cents: 299_99,
      wattage: 115,
      gpu_memory: 8,
      gpu_memory_type: 'GDDR6',
      gpu_core_clock_mhz: 1830,
      gpu_core_boost_mhz: 2460
    )

    expect(p1).to be_a(Cpu)
    expect(p2).to be_a(Gpu)
    expect(p1.type).to eq('Cpu')
    expect(p2.type).to eq('Gpu')
  end

  # --- Validations ---
  it 'requires brand and name and logs validation failed' do
    p = Part.new(type: 'Cpu', brand: '', name: '')
    expect(p).not_to be_valid
    p.valid? # triggers after_validation
    expect(p.errors.attribute_names).to include(:brand, :name)

    expect(logger_double).to have_received(:warn)
      .with(a_string_starting_with('[PART VALIDATION] Validation failed'))
      .at_least(:once)
  end

  it 'validates non-negative price_cents and wattage (nil allowed)' do
    expect(build_part(price_cents: nil, wattage: nil)).to be_valid

    p = build_part(price_cents: -1, wattage: -5)
    expect(p).not_to be_valid
    p.valid?
    expect(logger_double).to have_received(:warn)
      .with(a_string_including('[PART VALIDATION] Validation failed'))
      .at_least(:once)
  end

  it 'logs validation passed on a valid record' do
    p = build_part
    expect(p).to be_valid
    p.valid?
    expect(logger_double).to have_received(:debug)
      .with(a_string_starting_with('[PART VALIDATION] Validation passed'))
      .at_least(:once)
  end

  # --- price / price= ---
  describe '#price / #price=' do
    it 'returns nil when price_cents is nil' do
      p = build_part(price_cents: nil)
      expect(p.price).to be_nil
    end

    it 'converts cents to dollars using fdiv(100)' do
      p = build_part(price_cents: 12_34)
      expect(p.price).to eq(12.34)
    end

    it 'sets price_cents from numeric dollars via BigDecimal (floors with to_i)' do
      p = build_part(price_cents: nil)
      p.price = 10.999
      expect(p.price_cents).to eq(1_099)
    end

    it 'sets price_cents from string dollars' do
      p = build_part(price_cents: nil)
      p.price = '123.45'
      expect(p.price_cents).to eq(12_345)
    end

    it 'ignores blank assignment' do
      p = build_part(price_cents: 100)
      p.price = nil
      expect(p.price_cents).to eq(100)
    end
  end

  # --- Class logging helper ---
  describe '.log_query' do
    it 'logs scope and count with [PART QUERY] category' do
      Part.log_query('cheap_parts', 3)
      expect(logger_double).to have_received(:debug).with(
        a_string_matching(/\[PART QUERY\] cheap_parts: Found 3 part parts/i)
      )
    end
  end

  # --- Instance helpers ---
  describe '#price_in_dollars' do
    it 'returns 0 without logging when price_cents is nil' do
      p = build_part(price_cents: nil)
      expect(p.price_in_dollars).to eq(0)
      expect(logger_double).not_to have_received(:debug)
    end

    it 'returns dollars and logs conversion when price_cents present' do
      p = build_part(price_cents: 2_500)
      expect(p.price_in_dollars).to eq(25.0)
      expect(logger_double).to have_received(:debug).with(
        a_string_matching(/\[PART \d*\] Price conversion: 2500 cents = \$25\.0/)
      )
    end
  end

  describe '#usage_count' do
    it 'returns build_items count and logs usage' do
      p = create_part!
      b = Build.create!(name: 'Test Build')
      BuildItem.create!(build: b, part: p, quantity: 1)
      BuildItem.create!(build: b, part: p, quantity: 1)

      expect(p.usage_count).to eq(2)
      expect(logger_double).to have_received(:debug).with(
        a_string_matching(/\[PART #{p.id}\] Used in 2 builds/)
      )
    end
  end

  # --- Associations ---
  it 'has many build_items and builds through build_items' do
    p = create_part!
    b1 = Build.create!(name: 'B1')
    b2 = Build.create!(name: 'B2')
    BuildItem.create!(build: b1, part: p, quantity: 1)
    BuildItem.create!(build: b2, part: p, quantity: 1)

    expect(p.build_items.size).to eq(2)
    expect(p.builds.map(&:id)).to match_array([b1.id, b2.id])
  end

  # --- Callbacks & logging ---
  context 'callbacks and logging' do
    it 'logs [PART CREATE], [PART CREATED], [PART VALIDATION] (passed) on create' do
      p = Part.new(valid_cpu_attrs.merge(price_cents: nil))
      p.save!

      expect(logger_double).to have_received(:info).with(
        a_string_matching(/\[PART CREATE\] Creating new Cpu: AMD Ryzen 5 5600 - \$0(\.0)?, 65W/)
      )
      expect(logger_double).to have_received(:info).with(
        a_string_matching(/\[PART CREATED\] Successfully created Cpu ID: #{p.id} - AMD Ryzen 5 5600/)
      )
      expect(logger_double).to have_received(:debug)
        .with(a_string_starting_with('[PART VALIDATION] Validation passed'))
        .at_least(:once)
    end

    it 'logs [PART UPDATED] with saved changes (excluding updated_at)' do
      p = create_part!(wattage: 65)
      p.update!(wattage: 88)

      expect(logger_double).to have_received(:info).with(
        a_string_including("[PART UPDATED] Cpu ID: #{p.id} updated - Changes:", 'wattage')
      )
    end

    it 'logs [PART DESTROY] with usage count on destroy (no FK violation)' do
      p = create_part!
      # We want to assert the message with a non-zero usage without leaving rows that block destroy.
      allow(p).to receive_message_chain(:build_items, :count).and_return(2)

      expect { p.destroy! }.to change { Part.exists?(p.id) }.from(true).to(false)
      expect(logger_double).to have_received(:warn).with(
        a_string_matching(/\[PART DESTROY\] Destroying Cpu ID: #{p.id} - AMD Ryzen 5 5600 \(used in 2 builds\)/)
      )
    end

    it "uses 'Part' label in [PART CREATE] when type is nil" do
      p = Part.new(brand: 'Generic', name: 'Mystery', price_cents: 1000, wattage: 10)
      p.save!

      expect(logger_double).to have_received(:info).with(
        a_string_starting_with('[PART CREATE] Creating new Part: Generic Mystery - $10.0, 10W')
      )
      expect(logger_double).to have_received(:info).with(
        a_string_including('[PART CREATED] Successfully created ', 'Generic Mystery')
      )
    end
  end
end
