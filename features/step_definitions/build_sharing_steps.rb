# frozen_string_literal: true

# Build Sharing step definitions

When(/^I view my "([^"]*)" build$/) do |build_name|
  build = Build.find_by(name: build_name, user: @user)
  visit "/builds/#{build.id}"
end

When(/^I click "([^"]*)"$/) do |button_text|
  click_button button_text
end

When(/^someone visits the shared link$/) do
  @shared_build = Build.find_by(name: 'Ultimate Gaming Rig')
  @shared_build.generate_share_token!
  visit "/shared_builds/#{@shared_build.share_token}"
end

When(/^I am viewing their shared build$/) do
  other_user = User.create!(
    name: 'Other Builder',
    email: 'other@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )

  @shared_build = Build.create!(
    name: 'Shared Gaming Build',
    user: other_user
  )

  @shared_build.generate_share_token!
  visit "/shared_builds/#{@shared_build.share_token}"
end

When(/^I click "([^"]*)"$/) do |button_text|
  click_button button_text
end

When(/^I try to access the private build directly$/) do
  other_build = Build.find_by(name: 'Secret Build')
  visit "/builds/#{other_build.id}"
end

When(/^I make the build private$/) do
  @shared_build = Build.find_by(name: 'Ultimate Gaming Rig')
  @shared_build.update!(share_token: nil, shared_at: nil)
end

When(/^someone tries to visit the old shared link$/) do
  visit '/shared_builds/expired_token'
end

When(/^I visit the public builds gallery$/) do
  visit '/public_builds'
end

When(/^I search for "([^"]*)"$/) do |search_term|
  fill_in 'Search', with: search_term
  click_button 'Search'
end

When(/^I try to share the build$/) do
  visit "/builds/#{@build.id}"
  click_button 'Share Build'
end

Then(/^a shareable link should be generated$/) do
  expect(page).to have_css('input[readonly]', text: %r{http.*/shared_builds/})
end

Then(/^I should see "([^"]*)"$/) do |message|
  expect(page).to have_content(message)
end

Then(/^the link should be copyable$/) do
  expect(page).to have_button('Copy Link')
end

Then(/^they should see the build details$/) do
  expect(page).to have_content('Ultimate Gaming Rig')
  expect(page).to have_css('.build-details')
end

Then(/^they should see all components and specifications$/) do
  expect(page).to have_content('Ryzen 7 7800X3D')
  expect(page).to have_content('RTX 4070')
  expect(page).to have_content('DDR5-3600')
end

Then(/^they should see the total cost and wattage$/) do
  expect(page).to have_content(/Total Cost.*\$/)
  expect(page).to have_content(/Total Wattage.*W/)
end

Then(/^they should not be able to edit the build$/) do
  expect(page).not_to have_button('Edit')
  expect(page).not_to have_button('Add Component')
  expect(page).not_to have_button('Remove')
end

Then(/^they should see "([^"]*)"$/) do |text|
  expect(page).to have_content(text)
end

Then(/^they should see the creation date$/) do
  expect(page).to have_content(/Created on|Built on/)
end

Then(/^a new build should be created in my account$/) do
  expect(@user.builds.count).to be > 1
end

Then(/^all components should be copied over$/) do
  copied_build = @user.builds.order(:created_at).last
  expect(copied_build.build_items.count).to be.positive?
end

Then(/^I should be able to modify the copied build$/) do
  copied_build = @user.builds.order(:created_at).last
  visit "/builds/#{copied_build.id}"
  expect(page).to have_button('Add Component')
end

Then(/^I should be redirected to the public builds page$/) do
  expect(current_path).to eq('/public_builds')
end

Then(/^I should see a list of shared builds$/) do
  expect(page).to have_css('.shared-build-item')
end

Then(/^I should be able to filter by component type$/) do
  expect(page).to have_select('Filter by Component')
end

Then(/^I should be able to sort by popularity or date$/) do
  expect(page).to have_select('Sort by')
end

Then(/^I should see builds with "([^"]*)" in the name or description$/) do |search_term|
  build_items = page.all('.shared-build-item')
  expect(build_items.count).to be.positive?

  build_items.each do |item|
    expect(item.text.downcase).to include(search_term.downcase)
  end
end

Then(/^the results should be relevant to gaming builds$/) do
  expect(page).to have_content(/gaming/i)
end

Then(/^no shareable link should be generated$/) do
  expect(page).not_to have_css('input[readonly]')
end

# Background step definitions
Given(/^my build "([^"]*)" has been shared$/) do |build_name|
  build = Build.find_by(name: build_name, user: @user)
  build.generate_share_token!
  @shared_build = build
end

Given(/^another user has a private build "([^"]*)"$/) do |build_name|
  other_user = User.create!(
    name: 'Private User',
    email: 'private@example.com',
    password: 'password123',
    password_confirmation: 'password123'
  )

  Build.create!(
    name: build_name,
    user: other_user
  )
end

Given(/^multiple users have shared their builds$/) do
  3.times do |i|
    user = User.create!(
      name: "User #{i + 1}",
      email: "user#{i + 1}@example.com",
      password: 'password123',
      password_confirmation: 'password123'
    )

    build = Build.create!(
      name: "Gaming Build #{i + 1}",
      user: user
    )

    build.generate_share_token!
  end
end

Given(/^I have an incomplete build with no components$/) do
  @build = Build.create!(
    name: 'Empty Build',
    user: @user
  )
end

# Additional step definitions for undefined steps
Given('another user has shared a build publicly') do
  # Create another user and their shared build
  @other_user = User.create!(
    name: 'Other Builder',
    email: 'other@example.com',
    password: 'password123'
  )

  @shared_build = Build.create!(
    name: 'Shared Gaming Build',
    user: @other_user,
    shared: true
  )

  # Add some components to make it realistic
  cpu = Part.find_by(name: 'Ryzen 7 7800X3D') || Part.create!(name: 'Ryzen 7 7800X3D', type: 'Cpu', brand: 'AMD',
                                                              price: 399, wattage: 120)
  BuildItem.create!(build: @shared_build, part: cpu, quantity: 1)
end

Then('they should be redirected to the public builds page') do
  expect(current_path).to eq('/builds/public')
end
