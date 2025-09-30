require "rails_helper"

RSpec.describe User, type: :model do
  it "validates presence and format of email" do
    u = User.new(name: "Harsh", email: "harsh@example.com", password: "password123")
    expect(u).to be_valid
  end

  it "rejects invalid email" do
    u = User.new(name: "Harsh", email: "not-an-email", password: "password123")
    expect(u).not_to be_valid
  end

  it "enforces unique email case-insensitively" do
    User.create!(name: "A", email: "dup@example.com", password: "password123")
    u = User.new(name: "B", email: "DUP@example.com", password: "password123")
    expect(u).not_to be_valid
  end
end
