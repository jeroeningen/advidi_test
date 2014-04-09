require 'benchmark'
require 'curb'

# Please be sure that you have runned rake db:seed_fu and the images are in the folder public/system/banners/images
results = Benchmark.measure do
  10000.times do
    Curl.get("http://localhost:9292/campaigns/1")
  end
end

p results