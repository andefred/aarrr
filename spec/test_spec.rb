require "spec_helper"

feature "test" do
  scenario "test" do
    visit test_path
    page.should have_content "it works"
  end
end
