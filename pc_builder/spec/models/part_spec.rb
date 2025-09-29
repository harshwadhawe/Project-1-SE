require "rails_helper"

RSpec.describe Part, type: :model do
  it "creates STI subclasses correctly" do
    p1 = cpu
    p2 = gpu
    expect(p1).to be_a(Cpu)
    expect(p2).to be_a(Gpu)
    expect(p1.type).to eq("Cpu")
    expect(p2.type).to eq("Gpu")
  end

  it "requires brand and name" do
    expect { Part.create!(type: "Cpu", brand: "", name: "") }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
