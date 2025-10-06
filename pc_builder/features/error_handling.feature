@error_handling
Feature: Error Handling and Edge Cases
  As a user of the PC Builder application
  I want proper error handling and feedback
  So that I understand what went wrong and how to fix it

  @sad_path
  Scenario: Handle server errors gracefully
    Given I am logged in as a user
    When a server error occurs during build creation
    Then I should see a user-friendly error message
    And I should be able to retry the operation
    And the error should be logged for administrators

  @sad_path
  Scenario: Handle network connectivity issues
    Given I am creating a build
    When my network connection is lost
    Then I should see "Connection lost. Please check your internet and try again"
    And my unsaved changes should be preserved locally
    And I should be able to retry when connection is restored

  @sad_path
  Scenario: Handle invalid part data gracefully
    Given I am viewing the parts catalog
    When a part has missing or corrupted data
    Then the part should be marked as unavailable
    And other parts should still be displayed normally
    And I should see "Some parts are temporarily unavailable"

  @sad_path
  Scenario: Prevent duplicate components in build
    Given I am logged in as "builder@example.com"
    And I have a build with a "Ryzen 7 7800X3D" processor
    When I try to add another "Ryzen 7 7800X3D" processor
    Then I should see "This component is already in your build"
    And I should be offered to update the quantity instead

  @sad_path
  Scenario: Handle session expiration
    Given I am logged in and working on a build
    When my session expires
    Then I should be notified that my session has expired
    And I should be redirected to the login page
    And my unsaved work should be preserved after re-login

  @sad_path
  Scenario: Validate maximum build components
    Given I am logged in as "builder@example.com"
    And I have a build with the maximum allowed components
    When I try to add one more component
    Then I should see "Maximum number of components reached"
    And the component should not be added

  @happy_path
  Scenario: Recover from validation errors
    Given I am creating a new build
    When I submit invalid data
    And I see validation errors
    When I correct the errors and resubmit
    Then the build should be created successfully
    And I should see "Build created successfully"

  @sad_path
  Scenario: Handle incompatible components
    Given I am building a PC
    When I try to add incompatible components
    Then I should see compatibility warnings
    And I should be able to proceed with acknowledgment
    And I should be able to remove incompatible parts

  @sad_path
  Scenario: Handle insufficient user permissions
    Given I am a regular user
    When I try to access admin functionality
    Then I should see "Insufficient permissions"
    And I should be redirected to the appropriate page

  @happy_path
  Scenario: Provide helpful form validation
    Given I am filling out a form
    When I enter invalid data
    Then I should see real-time validation feedback
    And the errors should clearly explain what's wrong
    And I should see suggestions for fixing the errors