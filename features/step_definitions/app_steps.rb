Given /^I am on the homepage$/ do
  visit '/'
end

Then /^show me the page$/ do
  save_and_open_page
end
