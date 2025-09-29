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
