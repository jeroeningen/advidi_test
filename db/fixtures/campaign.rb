Campaign.seed do |c|
  c.id = 1
  c.name = "Test campaign"
  c.random_ratio = 100
  banners = []
  c.banners = banners
end

# The banners are seeded seperate from the campaign to overcome the error 'Errno::EMFILE: Too many open files - file -b --mime-type'
# To overcome the error that the campaign can't be found in the function 'banner_ids_from redis', the banners must be added AFTER the campaign is added
images = Dir.entries("#{Rails.root}/db/fixtures/images/").select {|f| !File.directory? f}
400.times do |i|
  Banner.seed do |b|
    b.id = i
    b.campaign_id = 1
    b.weight = (i % 2) + 1
    b.image = File.new("#{Rails.root}/db/fixtures/images/#{images[i]}")
  end
end