require 'rails_helper'
# this is using capybara
RSpec.describe 'Home features' do
  xit 'displays the name of the app' do
    visit root_path
    expect(page).to have_content('Your Logo')

    click_link('About')
    expect(current_path).to eql('/about')
    expect(page).to have_content('About')
  end
end
