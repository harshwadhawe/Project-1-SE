# frozen_string_literal: true
require "rails_helper"

RSpec.describe Cpu, type: :model do
  let(:logger_double) { instance_double(Logger, info: true, warn: true, debug: true) }

  before { allow(Rails).to receive(:logger).and_return(logger_double) }

  def cpu(attrs = {})
    Cpu.new({
      brand: "AMD",
      name: "Ryzen Test",
      price_cents: 199_99,
      wattage: 65,
      cpu_cores: 6,
      cpu_threads: 12,
      cpu_core_clock: 3.6,
      cpu_boost_clock: 4.4
    }.merge(attrs))
  end

  it "validates cores/threads if present and logs validation passed" do
    c = cpu
    expect(c).to be_valid
    c.valid?
    expect(logger_double).to have_received(:debug)
      .with(a_string_starting_with("[CPU VALIDATION] CPU validation passed")).at_least(:once)
  end

  it "logs validation failed when cores invalid" do
    c = cpu(cpu_cores: -1)
    expect(c).not_to be_valid
    c.valid?
    expect(logger_double).to have_received(:warn)
      .with(a_string_starting_with("[CPU VALIDATION] CPU validation failed")).at_least(:once)
  end

  it "#specs_summary returns a summary and logs specs" do
    c = cpu
    c.save!  # give it an id for the log
    summary = c.specs_summary
    expect(summary).to include("6C/12T", "3.6GHz", "4.4GHz", "65W")
    expect(logger_double).to have_received(:debug)
      .with(a_string_including("[CPU #{c.id}] Specs:")).at_least(:once)
    # also logs the detailed specs line when cores/threads present
    expect(logger_double).to have_received(:debug)
      .with(a_string_including("[CPU SPECS] AMD Ryzen Test: 6C/12T")).at_least(:once)
  end
end
