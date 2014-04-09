require File.expand_path("../../app", __FILE__)
require 'benchmark'

# The function Campaign.get_banner_ids_from_rdis looks to be very slow in the first place, 
# so I made a seperate test for it to tune it more easily
# Note that this benchmark assumes that you have seeded the database with 400 banners
campaign = Campaign.first
raise "Less then 400 banners available in this campaign" if campaign.banner_ids.size < 400
results = Benchmark.measure do
  5000.times do
    campaign.get_banner_ids_from_redis
  end
end

p results