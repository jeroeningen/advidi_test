require File.expand_path("../../app", __FILE__)
require 'benchmark'

# The function Campaign.get_banner_ids_from_rdis looks to be very slow in the first place, so I made a seperate test for it to tune it more easily
# Note that this benchmark assumes that you have seeded the database with 400 banners
results = Benchmark.measure do
  campaign = Campaign.first
  5000.times do
    campaign.get_banner_ids_from_redis
  end
end

p results