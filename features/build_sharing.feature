@build_sharing
Feature: Build Sharing and Collaboration
  As a PC builder
  I want to share my builds with others
  So that I can get feedback and showcase my configurations

  Background:
    Given I am logged in as "builder@example.com"
    And I have a completed build named "Ultimate Gaming Rig" with:
      | component       | quantity | price |
      | Ryzen 7 7800X3D | 1        | 399   |
      | RTX 4070        | 1        | 599   |
      | DDR5-3600       | 2        | 129   |

  @happy_path
  Scenario: Generate shareable link for build
    When I view my "Ultimate Gaming Rig" build
    And I click "Share Build"
    Then a shareable link should be generated
    And I should see "Build shared successfully"
    And the link should be copyable

  @happy_path
  Scenario: View shared build via public link
    Given my build "Ultimate Gaming Rig" has been shared
    When someone visits the shared link
    Then they should see the build details
    And they should see all components and specifications
    And they should see the total cost and wattage
    But they should not be able to edit the build

  @happy_path
  Scenario: Shared build displays creator information
    Given my build "Ultimate Gaming Rig" has been shared
    When someone visits the shared link
    Then they should see "Created by builder@example.com"
    And they should see the creation date

  @happy_path
  Scenario: Copy components from shared build
    Given another user has shared a build publicly
    And I am viewing their shared build
    When I click "Copy to My Builds"
    Then a new build should be created in my account
    And all components should be copied over
    And I should be able to modify the copied build

  @sad_path
  Scenario: Cannot access private build without permission
    Given another user has a private build "Secret Build"
    When I try to access the private build directly
    Then I should see "Build not found or access denied"
    And I should be redirected to the public builds page

  @sad_path
  Scenario: Shared link expires after build is made private
    Given my build "Ultimate Gaming Rig" has been shared
    And I make the build private
    When someone tries to visit the old shared link
    Then they should see "This build is no longer available"
    And they should be redirected to the public builds page

  @happy_path
  Scenario: Browse public builds gallery
    Given multiple users have shared their builds
    When I visit the public builds gallery
    Then I should see a list of shared builds
    And I should be able to filter by component type
    And I should be able to sort by popularity or date

  @happy_path
  Scenario: Search public builds
    Given multiple users have shared their builds
    When I visit the public builds gallery
    And I search for "gaming"
    Then I should see builds with "gaming" in the name or description
    And the results should be relevant to gaming builds

  @sad_path
  Scenario: Cannot share incomplete build
    Given I have an incomplete build with no components
    When I try to share the build
    Then I should see error "Cannot share empty build"
    And no shareable link should be generated