@authentication
Feature: User Authentication
  As a visitor to the PC Builder website
  I want to register and log in to my account
  So that I can save and manage my PC builds

  @happy_path
  Scenario: Successfully register a new account
    Given I am on the registration page
    When I register with valid credentials:
      | name     | John Builder        |
      | email    | john@example.com    |
      | password | SecurePass123!      |
    Then I should be logged in automatically
    And I should see "Welcome to PC Builder, John Builder!"

  @happy_path
  Scenario: Successfully log in with valid credentials
    Given I have an account with email "user@example.com" and password "password123"
    And I am on the login page
    When I log in with email "user@example.com" and password "password123"
    Then I should be logged in successfully
    And I should be redirected to the builds page

  @happy_path
  Scenario: Successfully log out
    Given I am logged in as "user@example.com"
    When I click the logout button
    Then I should be logged out
    And I should see the login page

  @sad_path
  Scenario: Cannot register with invalid email
    Given I am on the registration page
    When I register with invalid email "notanemail":
      | name     | John Builder   |
      | email    | notanemail     |
      | password | password123    |
    Then I should see error "Email is invalid"
    And I should remain on the registration page

  @sad_path
  Scenario: Cannot register with weak password
    Given I am on the registration page
    When I register with weak password "123":
      | name     | John Builder     |
      | email    | john@example.com |
      | password | 123              |
    Then I should see error "Password is too short"
    And the account should not be created

  @sad_path
  Scenario: Cannot register with duplicate email
    Given an account exists with email "existing@example.com"
    And I am on the registration page
    When I register with email "existing@example.com":
      | name     | John Builder        |
      | email    | existing@example.com|
      | password | password123         |
    Then I should see error "Email has already been taken"
    And the account should not be created

  @sad_path
  Scenario: Cannot log in with invalid credentials
    Given I have an account with email "user@example.com" and password "password123"
    And I am on the login page
    When I log in with email "user@example.com" and password "wrongpassword"
    Then I should see error "Invalid email or password"
    And I should remain on the login page

  @sad_path
  Scenario: Cannot access protected pages without authentication
    Given I am not logged in
    When I try to access the builds page
    Then I should be redirected to the login page
    And I should see "Please log in to continue"