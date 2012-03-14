require 'integration_helper'

describe "Channel", type: :request do

  before :each do
    make_user_and_login
  end

  it "should be able to create and delete", js: true do
    channel_title = "Teh hot channel"

    click_link "Add new"
    fill_in "channel_title", with: channel_title
    click_button "Submit"

    within(:css, "h1") do
      page.should have_content(channel_title)
    end

    # Visiting the edit page
    click_link "edit"
    handle_js_confirm(accept=true) do
      click_link "delete"
    end
  end

end