@javascript
Feature: Datagrid views
  In order to easily manage different views in the datagrid
  As a regular user
  I need to be able to create, update, apply and remove datagrid views

  Background:
    Given a "footwear" catalog configuration
    And the following products:
      | sku             | family   |
      | purple-sneakers | sneakers |
      | black-sneakers  | sneakers |
      | black-boots     | boots    |
    And I am logged in as "Mary"
    And I am on the products page

  Scenario: Successfully display the default view
    Then I should see "Views My default view"

  Scenario: Successfully create a new view
    Given I filter by "Family" with value "Sneakers"
    And I create the view:
      | label | Sneakers only |
    Then I should be on the products page
    And I should see "Datagrid view successfully created"
    And I should see "Views Sneakers only"
    And I should see products purple-sneakers and black-sneakers
    But I should not see product black-boots

  Scenario: Successfully apply a view
    Given I filter by "Family" with value "Boots"
    Then I should see product black-boots
    But I should not see products purple-sneakers and black-sneakers
    When I apply the "My default view" view
    Then I should see products black-boots, purple-sneakers and black-sneakers

  Scenario: Successfully update a view
    Given I filter by "Family" with value "Boots"
    And I create the view:
      | label | Some shoes |
    Then I should be on the products page
    And I should see "Datagrid view successfully created"
    And I should see "Views Some shoes"
    And I should see product black-boots
    But I should not see products purple-sneakers and black-sneakers
    When I hide the filter "Family"
    And I show the filter "Family"
    And I filter by "Family" with value "Sneakers"
    And I update the view
    And I apply the "Some shoes" view
    Then I should be on the products page
    And I should see "Views Some shoes"
    And I should see products purple-sneakers and black-sneakers
    But I should not see product black-boots

  Scenario: Successfully delete a view
    Given I filter by "Family" with value "Boots"
    And I create the view:
      | label | Boots only |
    Then I should be on the products page
    And I should see "Datagrid view successfully created"
    And I should see "Views Boots only"
    And I should see product black-boots
    But I should not see products purple-sneakers and black-sneakers
    When I delete the view
    And I confirm the deletion
    Then I should be on the products page
    And I should see "Datagrid view successfully removed"
    And I should see "Views My default view"
    But I should not see "Boots only"
    And I should see products black-boots, purple-sneakers and black-sneakers

  Scenario: Keep view per page
    When I change the page size to 25
    Given I am on the attributes page
    And I change the page size to 50
    When I am on the products page
    Then page size should be 25
    When I am on the attributes page
    Then page size should be 50
