require 'spec_helper'

feature "Administer Campaigns" do
  include Capybara::DSL
  
  Capybara.app = Sinatra::Application
  # Using selenium, because  I spent about two hours trying to install a more lightweight library
  Capybara.default_driver = :selenium
  
  before(:all) do
    @campaign_name = "Test campaign"
    @new_campaign_name = "Test2 campaign"
    @random_ratio = 65
  end
  
  scenario "Administer a campaign" do
    visit "/admin"
    current_path.should == "/admin/campaigns"
    
    visit "/admin/campaigns"
    page.should_not have_content @campaign_name
    
    # Create a campaign
    click_link "New campaign"
    fill_in "campaign[name]", :with => @campaign_name
    fill_in "campaign[random_ratio]", :with => @random_ratio
    click_button "Create campaign"
    Campaign.where(:name => @campaign_name, :random_ratio => @random_ratio).count.should == 1
    
    page.should have_content @campaign_name
    
    # Edit a campaign
    visit "/admin/campaigns/#{Campaign.last.id}/edit"
    fill_in "campaign[name]", :with => @new_campaign_name
    click_button "Update campaign"
    Campaign.where(:name => @new_campaign_name, :random_ratio => @random_ratio).count.should == 1

    # View a campaign in the frontend
    visit "/admin/campaigns/#{Campaign.last.id}"
    page.should have_content @new_campaign_name
    click_link "Show in frontend"
    #HACK: Body is tested for HTML image tag, because selenium doesnot support the function 'page.response_headers'
    page.body.should include "<img"
    # page.response_headers['Content-Type'].should == "image/png"
    
    #Add a banner
    visit "/admin/campaigns/#{Campaign.last.id}"
    Campaign.where(:name => @new_campaign_name, :random_ratio => @random_ratio).first.banners.size.should == 0
    click_link "Add banner"
    attach_file "banner[image]", "#{Dir.pwd}/db/fixtures/images/image_100.png"
    fill_in "banner[weight]", :with => 3
    click_button "Create banner"
    Campaign.where(:name => @new_campaign_name, :random_ratio => @random_ratio).first.banners.size.should == 1
    
    #Delete a banner
    visit "/admin/campaigns/#{Campaign.last.id}"
    click_button "Destroy banner"
    Campaign.where(:name => @new_campaign_name, :random_ratio => @random_ratio).first.banners.size.should == 0
    
    #Destroy the campaign
    visit "/admin/campaigns/#{Campaign.last.id}"
    click_button "Destroy campaign"
    Campaign.where(:name => @new_campaign_name).count.should == 0
  end
end