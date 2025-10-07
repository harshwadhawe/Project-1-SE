@pc_builds
Feature: PC Build Management
  As a PC builder enthusiast
  I want to create and manage PC builds
  So that I can plan and share my computer configurations

  Background:
    Given I have a user account with email "builder@example.com" and password "password123"
    And the following PC parts exist:
      | type | name           | brand | price | wattage |
      | Cpu  | Ryzen 7 7800X3D| AMD   | 399   | 120     |
      | Gpu  | RTX 4070       | NVIDIA| 599   | 200     |
      | Memory| DDR5-3600     | Corsair| 129  | 10      |

  @happy_path
  Scenario: Successfully create a new PC build
    Given I am logged in as "builder@example.com"
    When I create a new build named "Gaming Rig 2025"
    Then I should see "Gaming Rig 2025" in my builds list
    And the build should be associated with my account

  @happy_path
  Scenario: Add components to a PC build
    Given I am logged in as "builder@example.com"
    And I have a build named "Gaming Build"
    When I add the following components to my build:
      | component       | quantity |
      | Ryzen 7 7800X3D | 1        |
      | RTX 4070        | 1        |
      | DDR5-3600       | 2        |
    Then my build should contain 3 components
    And the total cost should be $1327
    And the total wattage should be 340W

  @happy_path
  Scenario: Calculate build totals automatically
    Given I am logged in as "builder@example.com"
    And I have a build with components
    When I view my build details
    Then I should see the total cost calculated correctly
    And I should see the total power consumption

  @sad_path
  Scenario: Cannot create build without name
    Given I am logged in as "builder@example.com"
    When I try to create a build without a name
    Then I should see an error "Name can't be blank"
    And the build should not be saved

  @sad_path
  Scenario: Cannot create build with extremely long name
    Given I am logged in as "builder@example.com"
    When I try to create a build with a name longer than 255 characters
    Then I should see an error about name length
    And the build should not be saved

  @sad_path
  Scenario: Cannot add components without valid quantity
    Given I am logged in as "builder@example.com"
    And I have a build named "Test Build"
    When I try to add a component with quantity 0
    Then I should see an error "Quantity must be greater than 0"
    And the component should not be added to the build

  @happy_path
  Scenario: Remove components from build
    Given I am logged in as "builder@example.com"
    And I have a build with a "Ryzen 7 7800X3D" component
    When I remove the "Ryzen 7 7800X3D" from my build
    Then the component should no longer be in my build
    And the build totals should be recalculated

  @sad_path
  Scenario: Cannot access another user's build
    Given I am logged in as "builder@example.com"
    And another user has a build named "Private Build"
    When I try to access the "Private Build"
    Then I should see an access denied error
    And I should be redirected to my builds page