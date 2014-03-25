#Advidi_test
This application serves banners for an advertising campaign.
So you are given the following business requirements:
* For every campaign, we want 2 banner­picking­mechanisms
** Random: Picking available banners randomly with equal chance.
** Weighted: The user is allowed to pick which banner will be displayed, and at which ratio. (E.g BannerA: 3, BannerB: 2, BannerC: 1 etc)
* We want to allow the user to set a ratio between these 2 banner­picking mechanisms. So let’s say, if the user sets 30% Random 70% Weighted, then when a request comes in (front­end), there is a 30% chance that it will pick Random, 70% chance it will use Weighted.
* The visitor should not see the same banner again until he has seen all other banners in that campaign.
* In the back­end, you should also allow the user to “weight” banners (set ratios, see above) within a campaign._

##How this application works
TODO

##Limitations / TODO's
* Already 'seen' images and the current request-ratio are stored in the session. This could result in a Cookie overflow if a campaign has too many images. A solution could be to store the session in the database or in Redis. In case of a database session store we should carefully check how many calls to the database will be done. In case of Redis I'm not sure whether Redis will be even fast when a lots of sessions are stored.
* Because of limited time, I skipped creating a very user friendly admin GUI with a slider for the ratio and a multiple file uploader to upload the images
* Because of limited time, I used Heroku for deployment, so no Capistrano script is added for deployment.
* For selecting a banner, native Ruby functions are used. These functions are mostly known as 'not so fast'. The cumulative density function might be the fastest way to select a banner or by using a hash to determine which banner ids are left. Unfortunately I did not have the time to impement it yet.
* If I can use a hash to determine which banner ids left, there is less space needed in the session for all ids
* Not thw complete Campaign is saved in Redis. Currently this causes one database query per request.

##Dependencies
Please install the following libraries:
* Postgres
* Redis

##Testing
Application tested using Rspec and Ruby 2.0.0p247
* Note that the test coverage of the function '.get_banner_and_requests_made(requests_made_and_banners_seen)' can be better.

##Bugs
* The Rspec test suite can't be completed in one run. Some tests fails and needs to be runned standalone.