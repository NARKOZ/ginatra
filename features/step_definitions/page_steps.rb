Given /^I am on '([^\']*)'$/ do |path|
  get path
end
 
When /^I open '([^\']*)'$/ do |path|
  get path
end
 
When /^I press "([^\"]*)"$/ do |button|
  click_button(button)
end
 
When /^I follow "([^\"]*)"$/ do |link|
  click_link(link)
end

When /^I fill in "([^\"]*)" with "([^\"]*)"$/ do |field, value|
  fill_in(field, :with => value) 
end
 
Then /^I should see "([^\"]*)"$/ do |text|
  last_response.should contain(text)
end
 
Then /^I should not see "([^\"]*)"$/ do |text|
  last_response.should_not contain(text)
end
 
Then /^I should be on (.+)$/ do |page_name|
  URI.parse(current_url).path.should == path_to(page_name)
end

Then /^Save and View$/ do
  save_and_open_page
end

