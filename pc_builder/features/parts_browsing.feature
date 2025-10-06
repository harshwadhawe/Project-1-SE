@parts_browsing
Feature: PC Parts Browsing and Selection
  As a PC builder
  I want to browse and filter available PC parts
  So that I can select the right components for my build

  Background:
    Given I am logged in as a PC builder
    And the following PC parts are available:
      | type       | name              | brand  | price | wattage | specifications           |
      | Cpu        | Ryzen 7 7800X3D   | AMD    | 399   | 120     | 8 cores, 16 threads     |
      | Cpu        | Intel i7-13700K   | Intel  | 419   | 125     | 16 cores, 24 threads    |
      | Gpu        | RTX 4070          | NVIDIA | 599   | 200     | 12GB GDDR6X             |
      | Gpu        | RTX 4080          | NVIDIA | 1199  | 320     | 16GB GDDR6X             |
      | Memory     | DDR5-3600 16GB    | Corsair| 129   | 10      | 16GB, 3600MHz           |
      | Storage    | NVMe SSD 1TB      | Samsung| 99    | 5       | 1TB, PCIe 4.0           |

  @happy_path
  Scenario: Browse all available parts
    When I visit the parts catalog
    Then I should see all 6 available parts
    And parts should be organized by category

  @happy_path
  Scenario: Filter parts by category
    When I visit the parts catalog
    And I filter by "Cpu" category
    Then I should see only CPU parts
    And I should see 2 CPU parts

  @happy_path
  Scenario: Filter parts by brand
    When I visit the parts catalog
    And I filter by "NVIDIA" brand
    Then I should see only NVIDIA parts
    And I should see 2 GPU parts

  @happy_path
  Scenario: Search parts by name
    When I visit the parts catalog
    And I search for "RTX"
    Then I should see parts containing "RTX" in the name
    And I should see 2 graphics cards

  @happy_path
  Scenario: View detailed part information
    When I visit the parts catalog
    And I click on "Ryzen 7 7800X3D"
    Then I should see detailed specifications
    And I should see the price "$399"
    And I should see the power consumption "120W"

  @happy_path
  Scenario: Sort parts by price
    When I visit the parts catalog
    And I sort by price ascending
    Then parts should be displayed in price order
    And "NVMe SSD 1TB" should appear before "DDR5-3600 16GB"

  @sad_path
  Scenario: Search returns no results
    When I visit the parts catalog
    And I search for "NonexistentPart"
    Then I should see "No parts found matching your search"
    And the search results should be empty

  @sad_path
  Scenario: Filter returns no results
    When I visit the parts catalog
    And I filter by a category with no parts
    Then I should see "No parts available in this category"
    And the filter results should be empty

  @happy_path
  Scenario: Add part to build from catalog
    Given I have a build named "My Gaming PC"
    When I visit the parts catalog
    And I add "Ryzen 7 7800X3D" to "My Gaming PC"
    Then the part should be added to my build
    And I should see a success message

  @sad_path
  Scenario: Cannot add part to build without selecting build
    When I visit the parts catalog
    And I try to add "Ryzen 7 7800X3D" without selecting a build
    Then I should see error "Please select a build first"
    And the part should not be added