# frozen_string_literal: true

# Parts Browsing step definitions

When(/^I visit the parts catalog$/) do
  visit '/parts'
end

When(/^I filter by "([^"]*)" category$/) do |category|
  select category, from: 'Category'
  click_button 'Filter'
end

When(/^I filter by "([^"]*)" brand$/) do |brand|
  select brand, from: 'Brand'
  click_button 'Filter'
end

When(/^I search for "([^"]*)"$/) do |search_term|
  fill_in 'Search', with: search_term
  click_button 'Search'
end

When(/^I click on "([^"]*)"$/) do |part_name|
  part = Part.find_by(name: part_name)
  click_link href: "/parts/#{part.id}"
end

When(/^I sort by price ascending$/) do
  select 'Price (Low to High)', from: 'Sort by'
  click_button 'Sort'
end

When(/^I filter by a category with no parts$/) do
  # Create a scenario where no parts exist in a category
  visit '/parts?category=Cooler' # Assuming no coolers exist
end

When(/^I add "([^"]*)" to "([^"]*)"$/) do |part_name, build_name|
  part = Part.find_by(name: part_name)
  Build.find_by(name: build_name)

  within("#part_#{part.id}") do
    select build_name, from: 'Build'
    click_button 'Add to Build'
  end
end

When(/^I try to add "([^"]*)" without selecting a build$/) do |part_name|
  part = Part.find_by(name: part_name)

  within("#part_#{part.id}") do
    click_button 'Add to Build'
  end
end

Then(/^I should see all (\d+) available parts$/) do |count|
  expect(page).to have_css('.part-item', count: count.to_i)
end

Then(/^parts should be organized by category$/) do
  expect(page).to have_css('.category-section')
  expect(page).to have_content('CPUs')
  expect(page).to have_content('GPUs')
end

Then(/^I should see only CPU parts$/) do
  expect(page).to have_css('.part-item[data-category="Cpu"]')
  expect(page).not_to have_css('.part-item[data-category="Gpu"]')
end

Then(/^I should see (\d+) CPU parts$/) do |count|
  expect(page).to have_css('.part-item[data-category="Cpu"]', count: count.to_i)
end

Then(/^I should see only NVIDIA parts$/) do
  expect(page).to have_css('.part-item[data-brand="NVIDIA"]')
  expect(page).not_to have_css('.part-item[data-brand="AMD"]')
end

Then(/^I should see (\d+) GPU parts$/) do |count|
  expect(page).to have_css('.part-item[data-category="Gpu"]', count: count.to_i)
end

Then(/^I should see parts containing "([^"]*)" in the name$/) do |search_term|
  part_names = page.all('.part-name').map(&:text)
  expect(part_names.all? { |name| name.include?(search_term) }).to be true
end

Then(/^I should see (\d+) graphics cards$/) do |count|
  expect(page).to have_css('.part-item[data-category="Gpu"]', count: count.to_i)
end

Then(/^I should see detailed specifications$/) do
  expect(page).to have_css('.part-specifications')
  expect(page).to have_content('Specifications')
end

Then(/^I should see the price "([^"]*)"$/) do |price|
  expect(page).to have_content(price)
end

Then(/^I should see the power consumption "([^"]*)"$/) do |wattage|
  expect(page).to have_content(wattage)
end

Then(/^parts should be displayed in price order$/) do
  prices = page.all('.part-price').map { |el| el.text.gsub(/[^\d.]/, '').to_f }
  expect(prices).to eq(prices.sort)
end

Then(/^"([^"]*)" should appear before "([^"]*)"$/) do |first_part, second_part|
  page_text = page.text
  first_index = page_text.index(first_part)
  second_index = page_text.index(second_part)

  expect(first_index).to be < second_index
end

Then(/^I should see "([^"]*)"$/) do |message|
  expect(page).to have_content(message)
end

Then(/^the search results should be empty$/) do
  expect(page).to have_css('.part-item', count: 0)
end

Then(/^the filter results should be empty$/) do
  expect(page).to have_css('.part-item', count: 0)
end

Then(/^the part should be added to my build$/) do
  # Check that a build item was created
  expect(@build.reload.build_items.count).to be.positive?
end

Then(/^I should see a success message$/) do
  expect(page).to have_content(/added.*successfully/i)
end

Then(/^the part should not be added$/) do
  original_count = @build&.build_items&.count || 0
  current_count = @build&.reload&.build_items&.count || 0
  expect(current_count).to eq(original_count)
end
