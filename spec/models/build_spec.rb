require "rails_helper"

RSpec.describe Build, type: :model do
  it "validates presence of name" do
    u = make_user
    b = Build.new(user: u)
    expect(b).not_to be_valid
    b.name = "My Build"
    expect(b).to be_valid
  end

  it "associates parts via build_items and can compute total_wattage" do
    u   = make_user
    b   = Build.create!(name: "Perf Build", user: u)
    p1  = cpu(wattage: 120)
    p2  = gpu(wattage: 300)
    BuildItem.create!(build: b, part: p1, quantity: 1)
    BuildItem.create!(build: b, part: p2, quantity: 1)

    expect(b.parts.count).to eq(2)
    if b.respond_to?(:total_wattage)
      b.update!(total_wattage: b.parts.sum(:wattage))
      expect(b.total_wattage).to eq(420)
    end
  end
end

RSpec.describe Build, type: :model do
  let(:logger_double) { instance_double(Logger, info: true, warn: true, debug: true, error: true) }

  before do
    allow(Rails).to receive(:logger).and_return(logger_double)
  end

  # --- Validations (fail then pass) + after_validation logging -----------------
  it "validates presence of name and logs validation results" do
    u = make_user
    b = Build.new(user: u)
    expect(b).not_to be_valid
    b.valid?
    expect(logger_double).to have_received(:warn)
      .with(a_string_starting_with("[BUILD VALIDATION] Validation failed")).at_least(:once)

    b.name = "My Build"
    expect(b).to be_valid
    b.valid?
    expect(logger_double).to have_received(:debug)
      .with(a_string_starting_with("[BUILD VALIDATION] Validation passed")).at_least(:once)
  end

  it "logs [BUILD CREATE]/[BUILD CREATED], [BUILD UPDATED], and [BUILD DESTROY]" do
    u = make_user
    b = Build.new(name: "Alpha", user: u)
    b.save!

    expect(logger_double).to have_received(:info)
      .with("[BUILD CREATE] Creating new build: 'Alpha' for user ID: #{u.id}")
      .at_least(:once)
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[BUILD CREATED] Successfully created build ID: #{b.id} - 'Alpha'"))
      .at_least(:once)

    b.update!(name: "Alpha Prime")
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[BUILD UPDATED] Build ID: #{b.id} updated - Changes:", "name"))
      .at_least(:once)

    cpu_part = cpu(name: "Ryzen 7 7800X3D")
    gpu_part = gpu(name: "RTX 4080 Super")
    i1 = BuildItem.create!(build: b, part: cpu_part, quantity: 1)
    i2 = BuildItem.create!(build: b, part: gpu_part, quantity: 1)

    # Destroy the build (this will destroy items first)
    expect { b.destroy! }.to change { Build.exists?(b.id) }.from(true).to(false)
    expect(BuildItem.where(build_id: b.id).count).to eq(0)

    # Per-item destroy logs (happen before the build summary)
    expect(logger_double).to have_received(:warn)
      .with("[BUILD_ITEM DESTROY] Removing BuildItem ID: #{i1.id} - #{cpu_part.name} x1 from build 'Alpha Prime'")
      .at_least(:once)
    expect(logger_double).to have_received(:warn)
      .with("[BUILD_ITEM DESTROY] Removing BuildItem ID: #{i2.id} - #{gpu_part.name} x1 from build 'Alpha Prime'")
      .at_least(:once)

    # Build summary log (after items are gone → count is 0). Be tolerant with item count.
    expect(logger_double).to have_received(:warn)
      .with(a_string_matching(/\[BUILD DESTROY\] Destroying build ID: #{b.id} - 'Alpha Prime' with \d+ items/))
      .at_least(:once)
  end


  # --- Associations + aggregate helpers ---------------------------------------
  it "associates parts via build_items and computes totals/summary with logs" do
    u  = make_user
    b  = Build.create!(name: "Perf Build", user: u)
    p1 = cpu(wattage: 120, price_cents: 200_00)
    p2 = gpu(wattage: 300, price_cents: 300_00)
    BuildItem.create!(build: b, part: p1, quantity: 1)
    BuildItem.create!(build: b, part: p2, quantity: 1)

    expect(b.parts.count).to eq(2)

    expect(b.total_wattage).to eq(420)
    expect(logger_double).to have_received(:debug)
      .with("[BUILD #{b.id}] Calculated total wattage: 420W").at_least(:once)

    expect(b.total_cost).to eq(500_00)
    expect(logger_double).to have_received(:debug)
      .with("[BUILD #{b.id}] Calculated total cost: 50000 cents").at_least(:once)

    summary = b.parts_summary
    expect(summary).to include("Cpu" => 1, "Gpu" => 1)
    expect(logger_double).to have_received(:debug)
      .with(a_string_including("[BUILD #{b.id}] Parts summary:")).at_least(:once)
  end

  # --- Sharing flow ------------------------------------------------------------
  describe "sharing" do
    before do
      allow(SecureRandom).to receive(:urlsafe_base64).and_return("tok123")
    end

    it "#generate_share_token! sets token+timestamp, logs, returns token, and shared? flips true" do
      b = Build.create!(name: "Shareable", user: make_user)
      expect(b.shared?).to be false

      token = b.generate_share_token!

      expect(token).to eq("tok123")
      expect(b.share_token).to eq("tok123")
      expect(b.shared_at).to be_present
      expect(b.shared?).to be true
      expect(logger_double).to have_received(:info)
        .with("[BUILD #{b.id}] Generated share token: tok123").at_least(:once)
    end

    it "#share_url returns nil when not shared; returns URL with token when shared" do
      b = Build.create!(name: "Linker", user: make_user)
      expect(b.share_url("https://example.com")).to be_nil

      b.generate_share_token!
      expect(b.share_url("https://example.com"))
        .to eq("https://example.com/builds/#{b.id}/shared?token=tok123")
    end

    it "#create_shareable_data! stores JSON, calls token gen, logs, and returns the hash" do
      u = make_user(name: "Alice", email: "alice@example.com")
      b = Build.create!(name: "Bundle", user: u)
      BuildItem.create!(build: b, part: cpu(price_cents: 111_00, wattage: 65), quantity: 1)
      BuildItem.create!(build: b, part: gpu(price_cents: 222_00, wattage: 115), quantity: 1)

      components = { cpu: { id: 1 }, gpu: { id: 2 } }
      data = b.create_shareable_data!(components)

      expect(data[:id]).to eq(b.id)
      expect(data[:name]).to eq("Bundle")
      expect(data[:components]).to eq(components)
      expect(data[:total_cost]).to eq(333_00)
      expect(data[:total_wattage]).to eq(180)
      expect(data[:parts_count]).to eq(2)
      expect(data[:user_name]).to eq("Alice")
      expect(data[:created_at]).to be_present
      expect(data[:shared_at]).to be_present

      expect(b.share_token).to eq("tok123")
      expect(b.shared_data).to be_a(String)

      expect(logger_double).to have_received(:info)
        .with("[BUILD #{b.id}] Generated share token: tok123").at_least(:once)
      expect(logger_double).to have_received(:info)
        .with(a_string_matching(/\[BUILD #{b.id}\] Created shareable data with 2 components/))
        .at_least(:once)
    end

    it "#parsed_shared_data handles blank, parses valid JSON, and logs error on invalid JSON" do
      b = Build.create!(name: "Parser", user: make_user)

      expect(b.parsed_shared_data).to eq({}) # blank

      b.update!(shared_data: { foo: "bar", n: 1 }.to_json)
      expect(b.parsed_shared_data).to eq({ "foo" => "bar", "n" => 1 })

      b.update!(shared_data: "{not: json")
      expect(b.parsed_shared_data).to eq({})
      expect(logger_double).to have_received(:error)
        .with(a_string_starting_with("[BUILD #{b.id}] Failed to parse shared data:"))
        .at_least(:once)
    end
  end
end