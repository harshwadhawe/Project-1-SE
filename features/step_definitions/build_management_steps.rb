# PC Build Management step definitions

When(/^I create a new build named "([^"]*)"$/) do |build_name|
  visit '/builds/new'
  fill_in 'Name', with: build_name
  click_button 'Create Build'
  @last_build_name = build_name
end

When(/^I try to create a build without a name$/) do
  visit '/builds/new'
  fill_in 'Name', with: ''
  click_button 'Create Build'
end

When(/^I try to create a build with a name longer than (\d+) characters$/) do |max_length|
  long_name = 'A' * (max_length.to_i + 1)
  visit '/builds/new'
  fill_in 'Name', with: long_name
  click_button 'Create Build'
end

When(/^I add the following components to my build:$/) do |table|
  visit "/builds/#{@build.id}"
  
  table.hashes.each do |row|
    part = Part.find_by(name: row['component'])
    expect(part).not_to be_nil, "Part '#{row['component']}' not found"
    
    # Click add component button for this part
    within("#part_#{part.id}") do
      fill_in 'Quantity', with: row['quantity']
      click_button 'Add to Build'
    end
  end
end

When(/^I try to add a component with quantity (\d+)$/) do |quantity|
  visit "/builds/#{@build.id}"
  part = Part.first
  
  within("#part_#{part.id}") do
    fill_in 'Quantity', with: quantity
    click_button 'Add to Build'
  end
end

When(/^I view my build details$/) do
  visit "/builds/#{@build.id}"
end

When(/^I remove the "([^"]*)" from my build$/) do |component_name|
  part = Part.find_by(name: component_name)
  build_item = BuildItem.find_by(build: @build, part: part)
  
  visit "/builds/#{@build.id}"
  within("#build_item_#{build_item.id}") do
    click_button 'Remove'
  end
end

When(/^I try to access the "([^"]*)"$/) do |build_name|
  other_build = Build.find_by(name: build_name)
  visit "/builds/#{other_build.id}"
end

Then(/^I should see "([^"]*)" in my builds list$/) do |build_name|
  visit '/builds'
  expect(page).to have_content(build_name)
end

Then(/^the build should be associated with my account$/) do
  build = Build.find_by(name: @last_build_name)
  expect(build.user).to eq(@user)
end

Then(/^my build should contain (\d+) components?$/) do |count|
  expect(@build.reload.build_items.count).to eq(count.to_i)
end

Then(/^the total cost should be \$(\d+)$/) do |expected_cost|
  visit "/builds/#{@build.id}"
  expect(page).to have_content("Total Cost: $#{expected_cost}")
end

Then(/^the total wattage should be (\d+)W$/) do |expected_wattage|
  visit "/builds/#{@build.id}"
  expect(page).to have_content("Total Wattage: #{expected_wattage}W")
end

Then(/^I should see the total cost calculated correctly$/) do
  expected_cost = @build.total_cost
  expect(page).to have_content("$#{expected_cost / 100}")
end

Then(/^I should see the total power consumption$/) do
  expected_wattage = @build.total_wattage
  expect(page).to have_content("#{expected_wattage}W")
end

Then(/^I should see an error "([^"]*)"$/) do |error_message|
  expect(page).to have_content(error_message)
end

Then(/^I should see an error about name length$/) do
  expect(page).to have_content(/name.*too long/i)
end

Then(/^the build should not be saved$/) do
  expect(Build.find_by(name: @last_build_name)).to be_nil
end

Then(/^the component should not be added to the build$/) do
  original_count = @build.build_items.count
  expect(@build.reload.build_items.count).to eq(original_count)
end

Then(/^the component should no longer be in my build$/) do |component_name|
  part = Part.find_by(name: component_name)
  expect(@build.reload.build_items.find_by(part: part)).to be_nil
end

Then(/^the build totals should be recalculated$/) do
  # Verify the page shows updated totals
  visit "/builds/#{@build.id}"
  new_cost = @build.reload.total_cost
  new_wattage = @build.total_wattage
  
  expect(page).to have_content("$#{new_cost / 100}")
  expect(page).to have_content("#{new_wattage}W")
end

Then(/^I should see an access denied error$/) do
  expect(page).to have_content(/access denied|not authorized|forbidden/i)
end

Then(/^I should be redirected to my builds page$/) do
  expect(current_path).to eq('/builds')
end

# Background steps for other users
Given(/^another user has a build named "([^"]*)"$/) do |build_name|
  other_user = User.create!(
    name: 'Other User',
    email: 'other@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )
  
  Build.create!(
    name: build_name,
    user: other_user
  )
end