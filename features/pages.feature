Feature: Page
  In order to use multiple repositories 
  As a browser
  I want to see the home page

  Scenario:
    When I go to the homepage
    Then I should see "Ginatra"
    And I should see "View My Rusty Git Repositories"
    And I should see "Test"
    And I should see "Unnamed repository; edit this file 'description' to name the repository."
  Scenario:
    When I open '/test'
    Then I should see "Ginatra"
    And I should see "Test"
    And I should see "Unnamed repository; edit this file 'description' to name the repository."
    And I should see "Commits"
    And I should see "(author)"
    And Save and View
  Scenario:
    When I open '/test/commit/eefb4c3'
    Then I should see "Ginatra"
    And I should see "Test"
    And I should see "Unnamed repository; edit this file 'description' to name the repository."
    And I should see "Commit eefb4c3"
    And I should see "doh, thanks lenary for reminding me of the files i'd forgotten"
  Scenario:
    When I open '/test/tree/24f701fd'
    Then I should see "Ginatra"
    And I should see "Test"
    And I should see "Unnamed repository; edit this file 'description' to name the repository."
    And I should see "Tree"
    And I should see "README.md"
    And I should see ".gitignore"
