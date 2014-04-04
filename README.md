#Advidi_test
This application serves banners for an advertising campaign.
So you are given the following business requirements:
* For every campaign, we want 2 banner­picking­mechanisms
** Random: Picking available banners randomly with equal chance.
** Weighted: The user is allowed to pick which banner will be displayed, and at which ratio. (E.g BannerA: 3, BannerB: 2, BannerC: 1 etc)
* We want to allow the user to set a ratio between these 2 banner­picking mechanisms. So let’s say, if the user sets 30% Random 70% Weighted, then when a request comes in (front­end), there is a 30% chance that it will pick Random, 70% chance it will use Weighted.
* The visitor should not see the same banner again until he has seen all other banners in that campaign.
* In the back­end, you should also allow the user to “weight” banners (set ratios, see above) within a campaign._

##Setup
Before starting your rails server, please run the following commands:
```
rake db:create
rake db:migrate
rake db:seed_fu
```

##How this application works
TODO

##Limitations / TODO's
* To speed up the application, please strip off as many Rails components where possible
* Already 'seen' images and the current request-ratio are stored in the session. This could result in a Cookie overflow if a campaign has too many images. A solution could be to store the session in the database or in Redis. In case of a database session store we should carefully check how many calls to the database will be done. In case of Redis I'm not sure whether Redis will be even fast when a lots of sessions are stored.
* Because of limited time, I skipped creating a very user friendly admin GUI with a slider for the ratio and a multiple file uploader to upload the images
* Because of limited time, I used Heroku for deployment, so no Capistrano script is added for deployment.
* For selecting a banner, native Ruby functions are used. These functions are mostly known as 'not so fast'. The cumulative density function might be the fastest way to select a banner or by using a hash to determine which banner ids are left. Unfortunately I did not have the time to impement it yet.
* If I can use a hash to determine which banner ids left, there is less space needed in the session for all ids
* Not thw complete Campaign is saved in Redis. Currently this causes one database query per request. Stripping off this, saves up about 7 seconds for 5.000 requests.
* The Redis function 'get_banner_ids_from_redis looks to be VERY VERY slow'
* Use RDoc for comments
* Use RubyProfiler for benchmarking
* Use another library besides 'Curb', because it looks to be that 'Curb' does not set a session

##Dependencies
Please install the following libraries:
* Postgres
* Redis

##Testing
Application tested using Rspec and Ruby 2.0.0p247
Please note the following:
* For testing purposes 400 test banners are included in this application, so you can easily seed the database. You can find them in the path 'db/fixtures/images'. In reality, this is quiet an ugly solution to include the images in the fixures directory.
* The test coverage of the function '.get_banner_and_requests_made(requests_made_and_banners_seen)' may not always return the right test results. In rare cases, the weighted request might return different values then expected.

##Bugs
* The Rspec test suite can't be completed in one run. Some tests might fail and needs to be runned standalone.
* In test mode the banner.image.content_type is nil.

##Benchmarking
Alll the benchmarks lives in the following directory 
```
spec/benchmarks/
````
For the requests I use the gem 'curb', becuase it is super fast as said in the conclusion of this article: http://bibwild.wordpress.com/2012/04/30/ruby-http-performance-shootout-redux/.
