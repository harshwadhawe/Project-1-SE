# frozen_string_literal: true

# Common steps shared across multiple features

# Authentication steps
Given(/^I have (?:a user account|an account) with email "([^"]*)" and password "([^"]*)"$/) do |email, password|
  @user = User.create!(
    name: email.split('@').first.capitalize,
    email: email,
    password: password,
    password_confirmation: password
  )
end

Given(/^I am logged in as "([^"]*)"$/) do |email|
  @user = User.find_by(email: email) || User.create!(
    name: email.split('@').first.capitalize,
    email: email,
    password: 'password123',
    password_confirmation: 'password123'
  )

  # For API-based authentication with JWT
  if page.driver.class.name.include?('Selenium')
    visit '/login'
    fill_in 'Email', with: email
    fill_in 'Password', with: 'password123'
    click_button 'Log In'
  else
    # For non-JS tests, set session directly
    page.set_rack_session('user_id' => @user.id)
  end
end

Given(/^I am logged in as a PC builder$/) do
  step 'I am logged in as "builder@example.com"'
end

Given(/^I am not logged in$/) do
  # Clear any existing session
  page.reset_session! if page.respond_to?(:reset_session!)
end

# Build steps
Given(/^I have a build named "([^"]*)"$/) do |build_name|
  @user ||= User.first || User.create!(
    name: 'Test User',
    email: 'test@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )

  @build = Build.create!(
    name: build_name,
    user: @user
  )
end

Given(/^I have a completed build named "([^"]*)" with:$/) do |build_name, table|
  step "I have a build named \"#{build_name}\""

  table.hashes.each do |row|
    part = find_or_create_part(row['component'])
    BuildItem.create!(
      build: @build,
      part: part,
      quantity: row['quantity'].to_i
    )
  end
end

Given(/^I have a build with (?:a )?(?:"([^"]*)" )?components?$/) do |component_name|
  step 'I have a build named "Test Build"'

  if component_name
    part = find_or_create_part(component_name)
    BuildItem.create!(build: @build, part: part, quantity: 1)
  else
    # Create a build with some default components
    cpu = find_or_create_part('Ryzen 7 7800X3D')
    gpu = find_or_create_part('RTX 4070')
    BuildItem.create!(build: @build, part: cpu, quantity: 1)
    BuildItem.create!(build: @build, part: gpu, quantity: 1)
  end
end

# Part creation steps
Given(/^the following PC parts (?:exist|are available):$/) do |table|
  table.hashes.each do |row|
    create_part_from_hash(row)
  end
end

# Helper methods
def find_or_create_part(name)
  # Try to find existing part first
  part = Part.find_by(name: name)
  return part if part

  # Create based on name patterns
  case name.downcase
  when /ryzen|amd/
    Cpu.create!(
      name: name,
      brand: 'AMD',
      price_cents: 39_900,
      wattage: 120,
      cpu_core_clock: 4.2,
      cpu_boost_clock: 5.0,
      cpu_cores: 8,
      cpu_threads: 16,
      model_number: name.gsub(/[^0-9A-Z]/i, '')
    )
  when /intel|i[3579]/
    Cpu.create!(
      name: name,
      brand: 'Intel',
      price_cents: 41_900,
      wattage: 125,
      cpu_core_clock: 3.4,
      cpu_boost_clock: 5.4,
      cpu_cores: 16,
      cpu_threads: 24,
      model_number: name.gsub(/[^0-9A-Z]/i, '')
    )
  when /rtx|gtx|nvidia/
    Gpu.create!(
      name: name,
      brand: 'NVIDIA',
      price_cents: 59_900,
      wattage: 200,
      gpu_memory: 12,
      gpu_memory_type: 'GDDR6X',
      gpu_base_clock: 1920,
      gpu_boost_clock: 2475,
      model_number: name.gsub(/[^0-9A-Z]/i, '')
    )
  when /ddr|memory|ram/
    Memory.create!(
      name: name,
      brand: 'Corsair',
      price_cents: 12_900,
      wattage: 10,
      memory_capacity: 16,
      memory_speed: 3600,
      memory_type: 'DDR5',
      model_number: name.gsub(/[^0-9A-Z]/i, '')
    )
  when /ssd|nvme|storage/
    Storage.create!(
      name: name,
      brand: 'Samsung',
      price_cents: 9900,
      wattage: 5,
      storage_capacity: 1000,
      storage_type: 'SSD',
      storage_interface: 'NVMe',
      model_number: name.gsub(/[^0-9A-Z]/i, '')
    )
  else
    # Default to CPU
    Cpu.create!(
      name: name,
      brand: 'Generic',
      price_cents: 10_000,
      wattage: 50,
      cpu_core_clock: 3.0,
      cpu_boost_clock: 4.0,
      cpu_cores: 4,
      cpu_threads: 8,
      model_number: 'GEN001'
    )
  end
end

def create_part_from_hash(hash)
  type_class = hash['type'].constantize

  attributes = {
    name: hash['name'],
    brand: hash['brand'],
    price_cents: (hash['price'].to_f * 100).to_i,
    wattage: hash['wattage'].to_i
  }

  # Add type-specific attributes
  case hash['type']
  when 'Cpu'
    attributes.merge!(
      cpu_core_clock: 3.8,
      cpu_boost_clock: 4.7,
      cpu_cores: 8,
      cpu_threads: 16,
      model_number: hash['name'].gsub(/[^0-9A-Z]/i, '')
    )
  when 'Gpu'
    attributes.merge!(
      gpu_memory: 12,
      gpu_memory_type: 'GDDR6X',
      gpu_base_clock: 1920,
      gpu_boost_clock: 2475,
      model_number: hash['name'].gsub(/[^0-9A-Z]/i, '')
    )
  when 'Memory'
    attributes.merge!(
      memory_capacity: 16,
      memory_speed: 3600,
      memory_type: 'DDR5',
      model_number: hash['name'].gsub(/[^0-9A-Z]/i, '')
    )
  when 'Storage'
    attributes.merge!(
      storage_capacity: 1000,
      storage_type: 'SSD',
      storage_interface: 'NVMe',
      model_number: hash['name'].gsub(/[^0-9A-Z]/i, '')
    )
  end

  type_class.create!(attributes)
end
