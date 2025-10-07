# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuildItem, type: :model do
  include TestHelpers

  let(:user) { make_user }
  let(:build) { Build.create!(name: 'Test Build', user: user) }
  let(:cpu_part) { cpu(price_cents: 30_000, wattage: 65) }
  let(:gpu_part) { gpu(price_cents: 50_000, wattage: 220) }

  describe 'validations' do
    it 'belongs to build and part, quantity > 0' do
      bi = BuildItem.new(build: build, part: cpu_part, quantity: 1)
      expect(bi).to be_valid
      bi.quantity = 0
      expect(bi).not_to be_valid
    end

    it 'validates presence of build' do
      bi = BuildItem.new(part: cpu_part, quantity: 1)
      expect(bi).not_to be_valid
      expect(bi.errors[:build]).to include('must exist')
    end

    it 'validates presence of part' do
      bi = BuildItem.new(build: build, quantity: 1)
      expect(bi).not_to be_valid
      expect(bi.errors[:part]).to include('must exist')
    end

    it 'validates quantity is greater than 0' do
      bi = BuildItem.new(build: build, part: cpu_part, quantity: -1)
      expect(bi).not_to be_valid
      expect(bi.errors[:quantity]).to include('must be greater than 0')
    end

    it 'allows nil quantity due to allow_nil: true' do
      bi = BuildItem.new(build: build, part: cpu_part, quantity: nil)
      expect(bi).to be_valid
    end

    it 'validates quantity is numeric' do
      bi = BuildItem.new(build: build, part: cpu_part, quantity: 'invalid')
      expect(bi).not_to be_valid
      expect(bi.errors[:quantity]).to include('is not a number')
    end
  end

  describe 'associations' do
    it 'belongs to build' do
      bi = BuildItem.create!(build: build, part: cpu_part, quantity: 1)
      expect(bi.build).to eq(build)
    end

    it 'belongs to part' do
      bi = BuildItem.create!(build: build, part: gpu_part, quantity: 1)
      expect(bi.part).to eq(gpu_part)
      expect(bi.part.name).to eq(gpu_part.name)
    end
  end

  describe 'total_cost method' do
    it 'calculates total cost correctly' do
      bi = BuildItem.create!(build: build, part: cpu_part, quantity: 2)

      expect(Rails.logger).to receive(:debug).with("[BUILD_ITEM #{bi.id}] Calculated total cost: 60000 cents (2 x 30000)")

      total = bi.total_cost
      expect(total).to eq(60_000) # 2 * 30000
    end

    it 'handles nil price_cents gracefully' do
      part_without_price = cpu(price_cents: nil)
      bi = BuildItem.create!(build: build, part: part_without_price, quantity: 3)

      expect(Rails.logger).to receive(:debug).with("[BUILD_ITEM #{bi.id}] Calculated total cost: 0 cents (3 x )")

      total = bi.total_cost
      expect(total).to eq(0)
    end

    it 'handles nil quantity gracefully (defaults to 1)' do
      bi = BuildItem.create!(build: build, part: cpu_part, quantity: nil)

      expect(Rails.logger).to receive(:debug).with("[BUILD_ITEM #{bi.id}] Calculated total cost: 30000 cents ( x 30000)")

      total = bi.total_cost
      expect(total).to eq(30_000) # nil quantity treated as 1
    end

    it 'handles both nil price and quantity' do
      part_without_price = cpu(price_cents: nil)
      bi = BuildItem.create!(build: build, part: part_without_price, quantity: nil)

      expect(Rails.logger).to receive(:debug).with("[BUILD_ITEM #{bi.id}] Calculated total cost: 0 cents ( x )")

      total = bi.total_cost
      expect(total).to eq(0)
    end
  end

  describe 'total_wattage method' do
    it 'calculates total wattage correctly' do
      bi = BuildItem.create!(build: build, part: gpu_part, quantity: 2)

      expect(Rails.logger).to receive(:debug).with("[BUILD_ITEM #{bi.id}] Calculated total wattage: 440W (2 x 220)")

      total = bi.total_wattage
      expect(total).to eq(440) # 2 * 220
    end

    it 'handles nil wattage gracefully' do
      part_without_wattage = cpu(wattage: nil)
      bi = BuildItem.create!(build: build, part: part_without_wattage, quantity: 2)

      expect(Rails.logger).to receive(:debug).with("[BUILD_ITEM #{bi.id}] Calculated total wattage: 0W (2 x )")

      total = bi.total_wattage
      expect(total).to eq(0)
    end

    it 'handles nil quantity gracefully (defaults to 1)' do
      bi = BuildItem.create!(build: build, part: gpu_part, quantity: nil)

      expect(Rails.logger).to receive(:debug).with("[BUILD_ITEM #{bi.id}] Calculated total wattage: 220W ( x 220)")

      total = bi.total_wattage
      expect(total).to eq(220)
    end

    it 'handles both nil wattage and quantity' do
      part_without_wattage = cpu(wattage: nil)
      bi = BuildItem.create!(build: build, part: part_without_wattage, quantity: nil)

      expect(Rails.logger).to receive(:debug).with("[BUILD_ITEM #{bi.id}] Calculated total wattage: 0W ( x )")

      total = bi.total_wattage
      expect(total).to eq(0)
    end
  end

  describe 'logging callbacks' do
    describe 'creation logging' do
      it 'logs build item creation attempt' do
        expect(Rails.logger).to receive(:info).with("[BUILD_ITEM CREATE] Adding part '#{cpu_part.name}' (ID: #{cpu_part.id}) to build '#{build.name}' (ID: #{build.id}) with quantity: 2")
        expect(Rails.logger).to receive(:info).with(/\[BUILD_ITEM CREATED\] Successfully created BuildItem ID: \d+ - #{cpu_part.name} x2 in build '#{build.name}'/)

        BuildItem.create!(build: build, part: cpu_part, quantity: 2)
      end

      it 'logs successful build item creation' do
        # Allow any logs during part/build creation
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:debug)

        # Expect the specific BuildItem logs in order
        expect(Rails.logger).to receive(:info).with("[BUILD_ITEM CREATE] Adding part '#{cpu_part.name}' (ID: #{cpu_part.id}) to build '#{build.name}' (ID: #{build.id}) with quantity: 2").ordered
        expect(Rails.logger).to receive(:info).with(/\[BUILD_ITEM CREATED\] Successfully created BuildItem ID: \d+ - #{cpu_part.name} x2 in build '#{build.name}'/).ordered

        BuildItem.create!(build: build, part: cpu_part, quantity: 2)
      end

      it 'handles nil quantity in creation logs (defaults to 1)' do
        expect(Rails.logger).to receive(:info).with("[BUILD_ITEM CREATE] Adding part '#{cpu_part.name}' (ID: #{cpu_part.id}) to build '#{build.name}' (ID: #{build.id}) with quantity: 1")
        expect(Rails.logger).to receive(:info).with(/\[BUILD_ITEM CREATED\] Successfully created BuildItem ID: \d+ - #{cpu_part.name} x in build '#{build.name}'/)

        BuildItem.create!(build: build, part: cpu_part, quantity: nil)
      end
    end

    describe 'validation logging' do
      it 'logs validation success' do
        # Allow other logger calls during user/build creation
        allow(Rails.logger).to receive(:debug)
        allow(Rails.logger).to receive(:info)

        # Expect the specific BuildItem validation log
        expect(Rails.logger).to receive(:debug).with('[BUILD_ITEM VALIDATION] Validation passed for BuildItem')

        bi = BuildItem.new(build: build, part: cpu_part, quantity: 1)
        bi.valid?
      end

      it 'logs validation failures' do
        allow(Rails.logger).to receive(:debug)
        allow(Rails.logger).to receive(:info)

        expect(Rails.logger).to receive(:warn).with(/\[BUILD_ITEM VALIDATION\] Validation failed for BuildItem: .+/)

        bi = BuildItem.new(build: build, part: cpu_part, quantity: -1)
        bi.valid?
      end
    end

    describe 'update logging' do
      it 'logs build item updates' do
        bi = BuildItem.create!(build: build, part: cpu_part, quantity: 1)

        allow(Rails.logger).to receive(:info) # Allow other logs
        expect(Rails.logger).to receive(:info).with(/\[BUILD_ITEM UPDATED\] BuildItem ID: #{bi.id} updated - Changes: .*quantity.*/)

        bi.update!(quantity: 3)
      end

      it 'does not log when no changes are made' do
        bi = BuildItem.create!(build: build, part: cpu_part, quantity: 1)

        # Should not receive any update log
        expect(Rails.logger).not_to receive(:info).with(/\[BUILD_ITEM UPDATED\]/)

        bi.touch # This doesn't change any tracked attributes except updated_at
      end
    end

    describe 'destruction logging' do
      it 'logs build item destruction' do
        bi = BuildItem.create!(build: build, part: cpu_part, quantity: 2)

        expect(Rails.logger).to receive(:warn).with("[BUILD_ITEM DESTROY] Removing BuildItem ID: #{bi.id} - #{cpu_part.name} x2 from build '#{build.name}'")

        bi.destroy
      end
    end
  end

  describe 'edge cases' do
    it 'handles missing part name gracefully in logging' do
      # Create a part without name by stubbing the method
      part_with_nil_name = cpu_part
      allow(part_with_nil_name).to receive(:name).and_return(nil)

      expect(Rails.logger).to receive(:info).with("[BUILD_ITEM CREATE] Adding part '' (ID: #{part_with_nil_name.id}) to build '#{build.name}' (ID: #{build.id}) with quantity: 1")
      allow(Rails.logger).to receive(:info) # Allow the created log

      BuildItem.create!(build: build, part: part_with_nil_name, quantity: 1)
    end

    it 'handles missing build name gracefully in logging' do
      # Create a build without name by stubbing the method
      build_with_nil_name = build
      allow(build_with_nil_name).to receive(:name).and_return(nil)

      expect(Rails.logger).to receive(:info).with("[BUILD_ITEM CREATE] Adding part '#{cpu_part.name}' (ID: #{cpu_part.id}) to build '' (ID: #{build_with_nil_name.id}) with quantity: 1")
      allow(Rails.logger).to receive(:info) # Allow the created log

      BuildItem.create!(build: build_with_nil_name, part: cpu_part, quantity: 1)
    end
  end

  describe 'legacy functionality tests' do
    it 'allows notes to be added' do
      bi = BuildItem.create!(build: build, part: cpu_part, quantity: 2, note: 'Need high performance')
      expect(bi.note).to eq('Need high performance')
    end

    it 'calculates total cost for quantity (legacy test)' do
      storage_part = storage(price_cents: 10_000) # $100
      bi = BuildItem.create!(build: build, part: storage_part, quantity: 2)

      total_cost = bi.quantity * storage_part.price_cents
      expect(total_cost).to eq(20_000) # $200
    end
  end
end
