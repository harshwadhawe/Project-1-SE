# frozen_string_literal: true
require "rails_helper"

RSpec.describe User, type: :model do
  let(:logger_double) { instance_double(Logger, info: true, warn: true, debug: true) }

  before do
    allow(Rails).to receive(:logger).and_return(logger_double)
  end

  let(:valid_attrs) do
    {
      name: "Spec User",
      email: "spec.user@example.com",
      password: "secret1",
      password_confirmation: "secret1"
    }
  end

  def build_user(overrides = {})
    described_class.new(valid_attrs.merge(overrides))
  end

  def create_user!(overrides = {})
    described_class.create!(valid_attrs.merge(overrides))
  end

  # --- Validations & normalization -------------------------------------------
  it "normalizes email (strip + downcase) and logs normalization + validation passed" do
    u = build_user(email: "  MixedCase@Example.COM  ")
    expect(u).to be_valid
    u.valid? # triggers before_validation + after_validation

    expect(u.email).to eq("mixedcase@example.com")
    expect(logger_double).to have_received(:debug)
      .with(a_string_starting_with("[USER VALIDATION] Email normalized:"))
      .at_least(:once)
    expect(logger_double).to have_received(:debug)
      .with(a_string_starting_with("[USER VALIDATION] Validation passed"))
      .at_least(:once)
  end

  it "requires name and email and valid email format; logs validation failed" do
    u = User.new(name: "", email: "bademail")
    expect(u).not_to be_valid
    u.valid?

    expect(u.errors.attribute_names).to include(:name, :email)
    expect(logger_double).to have_received(:warn)
      .with(a_string_starting_with("[USER VALIDATION] Validation failed"))
      .at_least(:once)
  end

  it "enforces email uniqueness case-insensitively" do
    create_user!(email: "unique@example.com")
    dup = build_user(email: "Unique@Example.com")
    expect(dup).not_to be_valid
    expect(dup.errors.attribute_names).to include(:email)
  end

  it "enforces password length >= 6 on create and when changed later" do
    u = build_user(password: "short", password_confirmation: "short")
    expect(u).not_to be_valid
    expect(u.errors.attribute_names).to include(:password)

    u = create_user! # valid
    u.password = "tiny"
    u.password_confirmation = "tiny"
    expect(u).not_to be_valid
    expect(u.errors.attribute_names).to include(:password)
  end

  # --- Callbacks (create/destroy) --------------------------------------------
  it "logs [USER CREATE] and [USER CREATED] on create" do
    u = build_user
    u.save!

    expect(logger_double).to have_received(:info)
      .with(a_string_starting_with("[USER CREATE] Creating new user: Spec User (spec.user@example.com)"))
      .at_least(:once)
    expect(logger_double).to have_received(:info)
      .with(a_string_including("[USER CREATED] Successfully created user ID: #{u.id} - Spec User (spec.user@example.com)"))
      .at_least(:once)
  end

  it "logs [USER DESTROY] with builds count and nullifies builds.user_id" do
    u = create_user!(email: "owner@example.com")
    b1 = Build.create!(name: "B1", user_id: u.id)
    b2 = Build.create!(name: "B2", user_id: u.id)

    expect { u.destroy! }.to change { User.exists?(u.id) }.from(true).to(false)

    expect(logger_double).to have_received(:warn)
      .with(a_string_matching(/\[USER DESTROY\] Destroying user ID: #{u.id} - Spec User \(owner@example.com\) with 2 builds/))
      .at_least(:once)

    expect(b1.reload.user_id).to be_nil
    expect(b2.reload.user_id).to be_nil
  end

  # --- JWT helpers ------------------------------------------------------------
  describe "JWT helpers" do
    it ".jwt_secret returns Rails.application.secret_key_base" do
      expect(described_class.jwt_secret).to eq(Rails.application.secret_key_base)
    end

    it "#generate_jwt_token encodes user_id and .decode_jwt_token returns the user" do
      u = create_user!(email: "jwtuser@example.com")
      token = u.generate_jwt_token
      expect(token).to be_a(String)

      decoded_user = described_class.decode_jwt_token(token)
      expect(decoded_user).to eq(u)
    end

    it ".decode_jwt_token returns nil for invalid token" do
      expect(described_class.decode_jwt_token("not.really.a.jwt")).to be_nil
    end

    it ".decode_jwt_token returns nil for expired token" do
      u = create_user!(email: "expired@example.com")
      payload = { user_id: u.id, exp: 1.hour.ago.to_i }
      expired_token = JWT.encode(payload, described_class.jwt_secret, "HS256")

      expect(described_class.decode_jwt_token(expired_token)).to be_nil
    end
  end
end
