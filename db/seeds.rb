Campaign.create :id => 1, :name => "Test campaign", :random_ratio => 100, :banners => []

# The banners are seeded seperate from the campaign to overcome the error 'Errno::EMFILE: Too many open files - file -b --mime-type'
# To overcome the error that the campaign can't be found in the function 'banner_ids_from redis', the banners must be added AFTER the campaign is added
images = Dir.entries("#{Dir.pwd}/db/fixtures/images/").select {|f| !File.directory? f}
400.times do |i|
  Banner.create :id => i, :campaign_id => 1, :weight => (i % 2) + 1, :image => File.open("#{Dir.pwd}/db/fixtures/images/#{images[i]}")
end