# frozen_string_literal: true
require "rails_helper"

RSpec.describe BuildItem, type: :model do
  let(:logger_double) { instance_double(Logger, info: true, warn: true, debug: true) }
  before { allow(Rails).to receive(:logger).and_return(logger_double) }

  def build_record
    Build.create!(name: "Spec Build")
  end

  def part_record
    Cpu.create!(
      brand: "AMD", name: "Ryzen Spec", price_cents: 150_00, wattage: 65,
      cpu_cores: 6, cpu_threads: 12, cpu_core_clock: 3.5, cpu_boost_clock: 4.4
    )
  end

  it "allows nil quantity but enforces > 0 when present; logs validation results" do
    bi = BuildItem.new(build: build_record, part: part_record, quantity: nil)
    expect(bi).to be_valid
    bi.valid?
    expect(logger_double).to have_received(:debug)
      .with("[BUILD_ITEM VALIDATION] Validation passed for BuildItem").at_least(:once)

    bi = BuildItem.new(build: build_record, part: part_record, quantity: 0)
    expect(bi).not_to be_valid
    bi.valid?
    expect(logger_double).to have_received(:warn)
      .with(a_string_starting_with("[BUILD_ITEM VALIDATION] Validation failed")).at_least(:once)
  end

  it "logs create / created / updated / destroy and computes totals" do
    b = build_record
    p = part_record

    # create
    bi = BuildItem.create!(build: b, part: p, quantity: 2)
    expect(logger_double).to have_received(:info)
      .with(a_string_starting_with("[BUILD_ITEM CREATE] Adding part")).at_least(:once)
    expect(logger_double).to have_received(:info)
      .with(a_string_starting_with("[BUILD_ITEM CREATED] Successfully created BuildItem ID:")).at_least(:once)

    # totals
    expect(bi.total_cost).to eq(2 * 150_00)
    expect(logger_double).to have_received(:debug)
      .with(a_string_including("[BUILD_ITEM #{bi.id}] Calculated total cost: 30000 cents")).at_least(:once)

    expect(bi.total_wattage).to eq(2 * 65)
    expect(logger_double).to have_received(:debug)
      .with(a_string_including("[BUILD_ITEM #{bi.id}] Calculated total wattage: 130W")).at_least(:once)

    # update
    bi.update!(quantity: 3)
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[BUILD_ITEM UPDATED] BuildItem ID: #{bi.id} updated - Changes:")).at_least(:once)

    # destroy
    expect { bi.destroy! }.to change { BuildItem.exists?(bi.id) }.from(true).to(false)
    expect(logger_double).to have_received(:warn)
      .with(a_string_including("[BUILD_ITEM DESTROY] Removing BuildItem ID: #{bi.id}")).at_least(:once)
  end
end
