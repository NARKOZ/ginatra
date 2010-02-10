Feature: Page
  In order to use multiple repositories 
  As a browser
  I want to see the home page
  
  Background:
    Given I am on the homepage

  Scenario: Viewing all the repositories
    Then I should see "Ginatra"
    And I should see "View My Git Repositories"
    And I should see "test"
    And I should see "description file for this repository and set the description for it."
    
  Scenario: Viewing a single repository
    When I follow "test"
    And I should see "description file for this repository and set the description for it."
    And I should see "Commits"
    # Perhaps "And I should see xxxxxx as the latest commit"
    And I should see "(author)"
    
  Scenario: Viewing a commit
    When I follow "test"
    And I should see "description file for this repository and set the description for it."
    When I follow "f41dfe45f0af1863f6309eef1b1a5980c59ccd16"
    And I should see "Commit: f41dfe4"
    And I should see "changes required for the client to work for now"
    
  Scenario: Viewing a file on a commit
    When I open '/test/tree/24f701fd'
    And I should see "test"
    And I should see "description file for this repository and set the description for it."
    And I should see "Tree: 24f701fd"
    And I should see "README.md"
    And I should see ".gitignore"
