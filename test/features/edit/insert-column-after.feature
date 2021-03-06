Feature: Insert Column After
  As a Data Packager  
  I want to insert another column after the current column  
  So that I can add more data to the data table  

  RULES
  =====

  - The "Insert Column After" command can be invoked using a menu item, keyboard shortcut or a context menu in the data tab

  Scenario: Insert Column After
    Given the cursor is in a data table
    When "Insert Column After" is invoked
    Then a column should be inserted after the current column
