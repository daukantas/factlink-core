require 'integration_helper'
  
def create_channel(user)
  channel = FactoryGirl.create(:channel, created_by: user.graph_user)
  channel
end
    
describe "channels" do
  
  before :each do
    @user = make_user_and_login
  end
  
  it "can be created", js: true do
    channel_title = "Teh hot channel"
    click_link "Add new"
    fill_in "channel_title", with: channel_title
    click_button "Create"

    within(:css, "h1") do
      page.should have_content(channel_title)
    end

    # Visiting the edit page and editing the page
    click_link "edit"
    channel_title_modified = "this is the corrected one"
    fill_in "channel_title", with: channel_title_modified
    click_button "Apply"

    within(:css, "h1") do
      page.should have_content(channel_title_modified)
    end

    click_link "edit"
    handle_js_confirm(accept=true) do
      click_link "Delete"
    end

    within(:css, "h1") do
      page.should_not have_content(channel_title_modified)
    end
  end

  it "can be visited", js: true do
    @channel = create_channel(@user)

    visit channel_path(@user, @channel)

    page.should have_content(@channel.title)
  end
end
