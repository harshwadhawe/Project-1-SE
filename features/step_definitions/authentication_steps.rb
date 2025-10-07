# User Authentication step definitions

Given(/^I am on the (?:registration|signup) page$/) do
  visit '/signup'
end

Given(/^I am on the login page$/) do
  visit '/login'
end

Given(/^an account exists with email "([^"]*)"$/) do |email|
  User.create!(
    name: email.split('@').first.capitalize,
    email: email,
    password: 'password123',
    password_confirmation: 'password123'
  )
end

When(/^I register with valid credentials:$/) do |table|
  credentials = table.hashes.first
  
  fill_in 'Name', with: credentials['name']
  fill_in 'Email', with: credentials['email']
  fill_in 'Password', with: credentials['password']
  fill_in 'Password Confirmation', with: credentials['password']
  click_button 'Sign Up'
end

When(/^I register with invalid email "([^"]*)":$/) do |invalid_email, table|
  credentials = table.hashes.first
  
  fill_in 'Name', with: credentials['name']
  fill_in 'Email', with: invalid_email
  fill_in 'Password', with: credentials['password']
  fill_in 'Password Confirmation', with: credentials['password']
  click_button 'Sign Up'
end

When(/^I register with weak password "([^"]*)":$/) do |weak_password, table|
  credentials = table.hashes.first
  
  fill_in 'Name', with: credentials['name']
  fill_in 'Email', with: credentials['email']
  fill_in 'Password', with: weak_password
  fill_in 'Password Confirmation', with: weak_password
  click_button 'Sign Up'
end

When(/^I register with email "([^"]*)":$/) do |email, table|
  credentials = table.hashes.first
  
  fill_in 'Name', with: credentials['name']
  fill_in 'Email', with: email
  fill_in 'Password', with: credentials['password']
  fill_in 'Password Confirmation', with: credentials['password']
  click_button 'Sign Up'
end

When(/^I log in with email "([^"]*)" and password "([^"]*)"$/) do |email, password|
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  click_button 'Log In'
end

When(/^I click the logout button$/) do
  click_link 'Logout'
end

When(/^I try to access the builds page$/) do
  visit '/builds'
end

Then(/^I should be logged in automatically$/) do
  expect(page).to have_content('Welcome to PC Builder')
  expect(page).to have_link('Logout')
end

Then(/^I should see "([^"]*)"$/) do |message|
  expect(page).to have_content(message)
end

Then(/^I should be logged in successfully$/) do
  expect(page).to have_link('Logout')
  expect(page).not_to have_link('Login')
end

Then(/^I should be redirected to the builds page$/) do
  expect(current_path).to eq('/builds')
end

Then(/^I should be logged out$/) do
  expect(page).to have_link('Login')
  expect(page).not_to have_link('Logout')
end

Then(/^I should see the login page$/) do
  expect(current_path).to eq('/login')
end

Then(/^I should see error "([^"]*)"$/) do |error_message|
  expect(page).to have_content(error_message)
end

Then(/^I should remain on the registration page$/) do
  expect(current_path).to eq('/signup')
end

Then(/^the account should not be created$/) do
  # Check that the last attempted email wasn't actually created
  last_email = page.find_field('Email').value rescue nil
  if last_email
    expect(User.find_by(email: last_email)).to be_nil
  end
end

Then(/^I should remain on the login page$/) do
  expect(current_path).to eq('/login')
end

Then(/^I should be redirected to the login page$/) do
  expect(current_path).to eq('/login')
end

Then(/^I should see "([^"]*)"$/) do |message|
  expect(page).to have_content(message)
end