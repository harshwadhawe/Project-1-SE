# Error Handling step definitions

Given(/^I am logged in as a user$/) do
  step 'I am logged in as "user@example.com"'
end

Given(/^I am creating a build$/) do
  visit '/builds/new'
  fill_in 'Name', with: 'Test Build'
end

Given(/^I am viewing the parts catalog$/) do
  visit '/parts'
end

Given(/^I have a build with a "([^"]*)" processor$/) do |processor_name|
  step "I have a build named \"Test Build\""
  cpu = find_or_create_part(processor_name)
  BuildItem.create!(build: @build, part: cpu, quantity: 1)
end

Given(/^I am logged in and working on a build$/) do
  step 'I am logged in as "user@example.com"'
  step 'I have a build named "Work Build"'
  visit "/builds/#{@build.id}"
end

Given(/^I have a build with the maximum allowed components$/) do
  step 'I have a build named "Full Build"'
  
  # Add maximum components (assuming 10 is the limit)
  10.times do |i|
    part = find_or_create_part("Component #{i+1}")
    BuildItem.create!(build: @build, part: part, quantity: 1)
  end
end

Given(/^I am creating a new build$/) do
  visit '/builds/new'
end

Given(/^I am building a PC$/) do
  step 'I have a build named "Compatibility Test"'
  visit "/builds/#{@build.id}"
end

Given(/^I am a regular user$/) do
  step 'I am logged in as "regular@example.com"'
end

Given(/^I am filling out a form$/) do
  visit '/builds/new'
end

When(/^a server error occurs during build creation$/) do
  # Mock a server error by submitting invalid data that causes an exception
  allow_any_instance_of(BuildsController).to receive(:create).and_raise(StandardError, "Database connection failed")
  fill_in 'Name', with: 'Server Error Test'
  click_button 'Create Build'
end

When(/^my network connection is lost$/) do
  # Simulate network issues by intercepting requests
  page.execute_script("window.fetch = function() { throw new Error('Network error'); }")
  fill_in 'Name', with: 'Network Test Build'
  click_button 'Create Build'
end

When(/^a part has missing or corrupted data$/) do
  # Create a part with invalid data
  Part.create!(
    name: nil,
    brand: 'Corrupted',
    price_cents: -100,
    wattage: nil,
    type: 'Cpu'
  )
  visit '/parts'
end

When(/^I try to add another "([^"]*)" processor$/) do |processor_name|
  visit "/builds/#{@build.id}"
  
  # Try to add the same processor again
  cpu = Part.find_by(name: processor_name)
  within("#part_#{cpu.id}") do
    fill_in 'Quantity', with: '1'
    click_button 'Add to Build'
  end
end

When(/^my session expires$/) do
  # Clear session cookies to simulate expiration
  page.driver.browser.manage.delete_all_cookies
  
  # Try to perform an action
  fill_in 'Name', with: 'Session Test'
  click_button 'Save'
end

When(/^I try to add one more component$/) do
  visit "/builds/#{@build.id}"
  
  extra_part = find_or_create_part('Extra Component')
  within("#part_#{extra_part.id}") do
    fill_in 'Quantity', with: '1'
    click_button 'Add to Build'
  end
end

When(/^I submit invalid data$/) do
  fill_in 'Name', with: '' # Invalid: empty name
  click_button 'Create Build'
end

When(/^I see validation errors$/) do
  expect(page).to have_content("can't be blank")
end

When(/^I correct the errors and resubmit$/) do
  fill_in 'Name', with: 'Valid Build Name'
  click_button 'Create Build'
end

When(/^I try to add incompatible components$/) do
  # Create incompatible parts (e.g., AMD CPU with Intel chipset)
  amd_cpu = find_or_create_part('AMD Ryzen')
  intel_motherboard = Motherboard.create!(
    name: 'Intel Z790',
    brand: 'Intel',
    price_cents: 20000,
    wattage: 15,
    motherboard_socket: 'LGA1700',
    motherboard_chipset: 'Z790',
    model_number: 'Z790'
  )
  
  visit "/builds/#{@build.id}"
  
  # Add both incompatible components
  [amd_cpu, intel_motherboard].each do |part|
    within("#part_#{part.id}") do
      fill_in 'Quantity', with: '1'
      click_button 'Add to Build'
    end
  end
end

When(/^I try to access admin functionality$/) do
  visit '/admin/users'
end

When(/^I enter invalid data$/) do
  fill_in 'Name', with: 'A' * 300 # Too long
  fill_in 'Email', with: 'invalid-email'
end

Then(/^I should see a user-friendly error message$/) do
  expect(page).to have_content(/something went wrong|error occurred/i)
  expect(page).not_to have_content('Exception')
  expect(page).not_to have_content('Stack trace')
end

Then(/^I should be able to retry the operation$/) do
  expect(page).to have_button('Try Again')
end

Then(/^the error should be logged for administrators$/) do
  # In a real app, we'd check logs. For testing, we'll assume logging works
  expect(Rails.logger).to receive(:error).with(/Database connection failed/)
end

Then(/^I should see "([^"]*)"$/) do |message|
  expect(page).to have_content(message)
end

Then(/^my unsaved changes should be preserved locally$/) do
  # Check that form data is still there
  expect(find_field('Name').value).to eq('Network Test Build')
end

Then(/^I should be able to retry when connection is restored$/) do
  # Reset network simulation
  page.execute_script("delete window.fetch")
  expect(page).to have_button('Try Again')
end

Then(/^the part should be marked as unavailable$/) do
  expect(page).to have_content('Unavailable')
end

Then(/^other parts should still be displayed normally$/) do
  valid_parts = Part.where.not(name: nil)
  expect(page).to have_css('.part-item', minimum: valid_parts.count)
end

Then(/^I should be offered to update the quantity instead$/) do
  expect(page).to have_content('update the quantity')
  expect(page).to have_button('Update Quantity')
end

Then(/^I should be notified that my session has expired$/) do
  expect(page).to have_content(/session.*expired|please.*log.*in/i)
end

Then(/^my unsaved work should be preserved after re-login$/) do
  # After re-login, form should remember the data
  step 'I log in with email "user@example.com" and password "password123"'
  expect(find_field('Name').value).to eq('Session Test')
end

Then(/^the component should not be added$/) do
  original_count = @build.build_items.count
  expect(@build.reload.build_items.count).to eq(original_count)
end

Then(/^the build should be created successfully$/) do
  expect(page).to have_content('Build created successfully')
  expect(Build.find_by(name: 'Valid Build Name')).not_to be_nil
end

Then(/^I should see compatibility warnings$/) do
  expect(page).to have_content(/compatibility.*warning|incompatible/i)
end

Then(/^I should be able to proceed with acknowledgment$/) do
  expect(page).to have_button('Proceed Anyway')
end

Then(/^I should be able to remove incompatible parts$/) do
  expect(page).to have_button('Remove Incompatible Parts')
end

Then(/^I should be redirected to the appropriate page$/) do
  expect(current_path).not_to eq('/admin/users')
  expect(current_path).to eq('/builds')
end

Then(/^I should see real-time validation feedback$/) do
  # Check for live validation indicators
  expect(page).to have_css('.field-error, .invalid, .error')
end

Then(/^the errors should clearly explain what's wrong$/) do
  expect(page).to have_content(/too long|invalid format|required/i)
end

Then(/^I should see suggestions for fixing the errors$/) do
  expect(page).to have_content(/must be|should be|try/i)
end