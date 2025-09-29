require "rails_helper"

RSpec.describe BuildItem, type: :model do
  it "belongs to build and part, quantity > 0" do
    u  = make_user
    b  = Build.create!(name: "Test Build", user: u)
    p  = cpu
    bi = BuildItem.new(build: b, part: p, quantity: 1)
    expect(bi).to be_valid
    bi.quantity = 0
    expect(bi).not_to be_valid
  end
end
