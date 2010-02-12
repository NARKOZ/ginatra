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
    When I follow "095955b6402c30ef24520bafdb8a8687df0a98d3"
    And I should see "Commit: 095955b"
    And I should see "first pass at having the hancock client"
    
  Scenario: Viewing a file on a commit
    When I open '/test/tree/6f27ba2f'
    And I should see "test"
    And I should see "description file for this repository and set the description for it."
    And I should see "Tree: 6f27ba2f"
    And I should see "README.md"
    And I should see ".gitignore"
