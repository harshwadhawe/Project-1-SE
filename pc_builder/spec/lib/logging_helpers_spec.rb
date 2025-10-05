# frozen_string_literal: true
require "rails_helper"

RSpec.describe "DatabaseLogger concern", type: :model do
  let(:logger_double) { instance_double(Logger, info: true, warn: true, debug: true, error: true) }
  before { allow(Rails).to receive(:logger).and_return(logger_double) }

  before(:all) do
    # Use a real table so AR callbacks run; name doesn't need to be "Build"
    class DbLogBuild < ApplicationRecord
      self.table_name = "builds"
      include DatabaseLogger
    end
  end

  after(:all) do
    Object.send(:remove_const, :DbLogBuild) if defined?(DbLogBuild)
  end

  it "logs class-level query helpers (start/completed/slow)" do
    # Fast path
    t0 = Time.current
    t1 = t0 + 0.05
    allow(Time).to receive(:current).and_return(t0, t1)

    DbLogBuild.log_query("where", name: "X")
    # Be flexible about hash formatting ({name: "X"} vs {:name=>"X"})
    expect(logger_double).to have_received(:debug)
      .with(a_string_including("[DBLOGBUILD_QUERY] where:", "name", "X")).at_least(:once)

    result = DbLogBuild.with_query_logging("fast list") { [1,2,3] }
    expect(result).to eq([1,2,3])
    expect(logger_double).to have_received(:debug)
      .with(a_string_including("[DBLOGBUILD_QUERY] Starting: fast list")).at_least(:once)
    expect(logger_double).to have_received(:debug)
      .with(a_string_matching(/\[DBLOGBUILD_QUERY\] Completed: fast list - .* records in \d+\.\d{1,2}ms/)).at_least(:once)

    # Slow path (>100ms)
    t2 = Time.current
    t3 = t2 + 0.201
    allow(Time).to receive(:current).and_return(t2, t3)

    DbLogBuild.with_query_logging("slow list") { [1] }
    expect(logger_double).to have_received(:warn)
      .with(a_string_including("[DBLOGBUILD_SLOW_QUERY] slow list took")).at_least(:once)
  end

  it "logs instance lifecycle via callbacks (create/update/destroy) and after_initialize on persisted" do
    # CREATE
    rec = DbLogBuild.new(name: "Alpha")
    rec.save!

    # Because class name is DbLogBuild (not 'Build'), summary falls back to 'ID:...'
    expect(logger_double).to have_received(:info)
      .with(a_string_starting_with("[DBLOGBUILD] Creating: ID:")).at_least(:once)
    expect(logger_double).to have_received(:info)
      .with(a_string_starting_with("[DBLOGBUILD] Created: ID:#{rec.id} - ID:")).at_least(:once)

    # after_initialize on persisted records
    reloaded = DbLogBuild.find(rec.id)
    expect(reloaded.id).to eq(rec.id)
    expect(logger_double).to have_received(:debug)
      .with(a_string_including("[DBLOGBUILD] Initialized: ID:")).at_least(:once)

    # UPDATE
    rec.update!(name: "Alpha Prime")
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[DBLOGBUILD] Updating ID:#{rec.id} - Changed: name")).at_least(:once)
    expect(logger_double).to have_received(:info)
      .with("[DBLOGBUILD] Updated: ID:#{rec.id}").at_least(:once)

    # DESTROY
    expect { rec.destroy! }.to change { DbLogBuild.exists?(rec.id) }.from(true).to(false)
    expect(logger_double).to have_received(:warn)
      .with(a_string_including("[DBLOGBUILD] Destroying: ID:#{rec.id} - ID:")).at_least(:once)
    expect(logger_double).to have_received(:warn)
      .with("[DBLOGBUILD] Destroyed: ID:#{rec.id}").at_least(:once)
  end
end
