# frozen_string_literal: true
require "rails_helper"

RSpec.describe "LoggingHelpers + MemoryLogger + PerformanceMonitor" do
  let(:logger_double) { instance_double(Logger, info: true, warn: true, debug: true, error: true) }
  before { allow(Rails).to receive(:logger).and_return(logger_double) }

  class DummyThing
    include LoggingHelpers
    attr_accessor :id
    def initialize(id=nil); @id = id; end
  end

  it "class and instance helpers log as expected" do
    # Class method
    DummyThing.log_class_action("Boot", foo: 1)
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[DUMMYTHING] Boot:", "foo", "1")).at_least(:once)

    # Instance action without id
    DummyThing.new.log_action("do", x: 1)
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[DUMMYTHING] do:", "x", "1")).at_least(:once)

    # Instance action with id
    DummyThing.new(42).log_action("do", y: 2)
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[DUMMYTHING ID:42] do:", "y", "2")).at_least(:once)

    # Error logging (message + context + backtrace)
    err = RuntimeError.new("kaboom")
    err.set_backtrace(%w[a.rb:1 b.rb:2 c.rb:3])
    DummyThing.new(7).log_error(err, action: "test")
    expect(logger_double).to have_received(:error)
      .with("[DUMMYTHING ID:7] ERROR: kaboom").at_least(:once)
    expect(logger_double).to have_received(:error)
      .with(a_string_including("[DUMMYTHING ID:7] CONTEXT:", "action", "test")).at_least(:once)
    expect(logger_double).to have_received(:error)
      .with(a_string_starting_with("[DUMMYTHING ID:7] BACKTRACE: a.rb:1")).at_least(:once)

    # User/business/security/api helpers
    DummyThing.new.log_user_activity(9, "clicked", btn: "save")
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[USER_ACTIVITY] User:9 - clicked:", "btn", "save")).at_least(:once)

    DummyThing.new.log_business_logic("build_created", id: 1)
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[BUSINESS_LOGIC] build_created:", "id", "1")).at_least(:once)

    DummyThing.new.log_security_event("xss_detected", :warn, path: "/q")
    expect(logger_double).to have_received(:warn)
      .with(a_string_including("[SECURITY] xss_detected:", "path", "/q")).at_least(:once)

    DummyThing.new.log_api_interaction("Payments", "charge", {amount: 5}, {status: "ok"})
    expect(logger_double).to have_received(:info)
      .with("[API] Payments - charge").at_least(:once)
    expect(logger_double).to have_received(:debug)
      .with(a_string_starting_with("[API_REQUEST] Payments:")).at_least(:once)
    expect(logger_double).to have_received(:debug)
      .with(a_string_starting_with("[API_RESPONSE] Payments:")).at_least(:once)
  end

  it "performance helpers log fast vs slow paths" do
    thing = DummyThing.new(5)

    # fast (<=100ms)
    t0 = Time.current; t1 = t0 + 0.05
    allow(Time).to receive(:current).and_return(t0, t1)
    res = thing.log_performance("fast op") { :ok }
    expect(res).to eq(:ok)
    expect(logger_double).to have_received(:debug)
      .with(a_string_including("[DUMMYTHING ID:5] PERFORMANCE: fast op took")).at_least(:once)

    # slow (>100ms)
    t2 = Time.current; t3 = t2 + 0.201
    allow(Time).to receive(:current).and_return(t2, t3)
    thing.log_performance("slow op") { :ok }
    expect(logger_double).to have_received(:warn)
      .with(a_string_including("[DUMMYTHING ID:5] SLOW_OPERATION: slow op took")).at_least(:once)
  end

  it "log_database_query logs duration and slow query warning at 500ms" do
    # fast
    t0 = Time.current; t1 = t0 + 0.2
    allow(Time).to receive(:current).and_return(t0, t1)
    DummyThing.new.log_database_query("users/index") { 123 }
    expect(logger_double).to have_received(:debug)
      .with(a_string_including("[DATABASE] users/index")).at_least(:once)

    # slow
    t2 = Time.current; t3 = t2 + 0.6
    allow(Time).to receive(:current).and_return(t2, t3)
    DummyThing.new.log_database_query("users/slow") { 1 }
    expect(logger_double).to have_received(:warn)
      .with(a_string_including("[SLOW_QUERY] users/slow took")).at_least(:once)
  end

  it "MemoryLogger.log_memory_usage logs GC/memory line (skip ps on Windows)" do
    stub_const("RUBY_PLATFORM", "mswin") # avoids backtick `ps`
    MemoryLogger.log_memory_usage("TEST")
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[MEMORY TEST] Objects:", "GC Count:")).at_least(:once)
  end

  it "PerformanceMonitor.monitor_action logs performance and slow-action branch" do
    controller = "Builds"; action = "index"

    # fast
    t0 = Time.current; t1 = t0 + 0.2
    allow(Time).to receive(:current).and_return(t0, t1)
    out = PerformanceMonitor.monitor_action(controller, action) { :ok }
    expect(out).to eq(:ok)
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[PERFORMANCE] Builds#index completed in")).at_least(:once)

    # slow (>500ms)
    t2 = Time.current; t3 = t2 + 0.75
    allow(Time).to receive(:current).and_return(t2, t3)
    PerformanceMonitor.monitor_action(controller, action) { :ok }
    expect(logger_double).to have_received(:warn)
      .with(a_string_including("[SLOW_ACTION] Builds#index took")).at_least(:once)
  end
end
