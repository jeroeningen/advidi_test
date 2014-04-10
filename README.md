#Advidi_test
This application serves banners for an advertising campaign.
So you are given the following business requirements:
* For every campaign, we want 2 banner­picking­mechanisms
** Random: Picking available banners randomly with equal chance.
** Weighted: The user is allowed to pick which banner will be displayed, and at which ratio. (E.g BannerA: 3, BannerB: 2, BannerC: 1 etc)
* We want to allow the user to set a ratio between these 2 banner­picking mechanisms. So let’s say, if the user sets 30% Random 70% Weighted, then when a request comes in (front­end), there is a 30% chance that it will pick Random, 70% chance it will use Weighted.
* The visitor should not see the same banner again until he has seen all other banners in that campaign.
* In the back­end, you should also allow the user to “weight” banners (set ratios, see above) within a campaign._

##Foreword
Please note that this README is written for reviewing purposes. 
In the first place, this README is not written for people who just wants to use this application.
This application does have more comments then I should normally use. This is to explain all my decisions in as much detail as possible.

Due to a lack of time this project still has 'TODO's' and limitations. Because of the lack of time I focussed most on the following points:
* eliminate major bugs
* eliminate minor bugs as much as possible
* meet the requirements of the test
You can find the limitations, TODO's and known bugs later in this document.

##Dependencies
Please install the following libraries:
* Postgres
* Redis

##Setup
First, create a file config/database.rb and set the databases like this:
```
configure :development do
  set :database, 'postgres://<username>:<password>@localhost/<database>'
end

configure :production do
end

configure :test do
  set :database, 'postgres://<username>:<password>@localhost/<database>'
end
```

Before starting your server, please run the following command:
```
rake db:create
rake db:migrate
rake db:seed
```

You can test the application with the following command:
```
rspec
```

##Starting the app
Please run the following command to start the app
```
rackup
```

##Using the app
The username and password for the admin-interface are advidi / advidi

To access the console please run the following command from the application root:
```
tux
```

Please run all the commands from the applicaton root, otherwise commands may not work because of the usage of the fuunction 
```
Dir.pwd
```

##Still problems with the app?
If you still have problems setting up or running the application, please contact me at jeroeningen <at> gmail dot com.

##How this application works
In this section I only describe the core-functionality as mentioned in the description of the test. I do not describe the amin-interface.

###What's in the session
The session has an hash named 'banner_and_requests_made'. In this hash the following is stored:
* requests_made - Array of the requests a user already made. See also section 'Campaign.request'.
* current_banner_id - ID of the banner to be shown (current banner)
* banner_ids_left - Banner IDs of banners not seen yet.
* current_banner_path - Path to the current banner image
* current_banner_ontent_type - Content type of the current banner

###Do a request
If the user does a request there are three steps to be made.
1. The campaign will be retrieved from Redis.
2. The function 'Campaign.get_banner_and_requests_made' determines the next banner based on the requests already made. See also the sections 'Campaign.request' and 'Campaign.get_banner_and_requests_made'.
3. Send the new banner to the user.

###Campaign.request
This function determines whether a random or a weighted request should be made based on the requests already made. The 'requests already made' are passed as argument. This array includes the following keys:
* random - number of random requests made
* weighted - number of weighted requests made
* current_request - type of request to be made. Can be either 'random' or 'weighted'
* common_denominator - used to determine the minimum requests to be made to get the right ratio of weighted and random requests
Note that it should be better to move the common denominator to the Campaign model as attribute.

The method works as follows:
1. If the number of random and number of weighted requests are not present, they will be initialized with '0'.
2. If the common denominator is not present, it wil be initialized as follows:
If the random_ratio is either 0 or 100, the common_denominator will be '1'.
Otherwise, the highest value will be determined that is divisible by the percentage random requests and divisible by the percentage weighted requests. To determine the 'minimum maximum' random requests and  'minimum maximum' weighted requests to be made, the common denominator is used.
3. Determine as follows which request should be made: 
If the generated value is lower then the random ratio and the number of random requests made is lower then the maximum number random requests made, do a random request.
If the maximum number of weighted requests made, do a random request.
In all other cases do a weighted request

###Campaign.get_banner_and_requests_made
This function determines the next banner to be shown based on the requests already made. The 'banner and requests made' are passed as an argument. See section 'What's in the session' for the keys included in this array.

The method works as folllows:
1. If the 'banner_and_requests_made' hash is not available, initialize it. Needed for the first request.
2. If the key 'requests_made' in the hash 'banners_and_requests_made' is not available, initialize it. Needed for the first request.
3. Initialize the current banner ID to '0'.
4. Get the 'banner IDs left'. For the first request, it must be retrieved from Redis.
5. Determine the next request type based on the requests already made.
6. Determine the next banner. If the request is random, each banner has an equal chance to be chosen. If the request is weighted, the weight of the banner will be taken into account.
7. Delete the next banner ID from the hash banner IDs left.
8. Create the new hash for the session.

###Creating a campaign
When a campaign is created, the random ratio is added to Redis in a hash key. The random ratio can be found by the Campaign ID as key.

###Deleting a campaign
When a campaign is deleted, the random ratio will be removed from Redis.

###Creating a banner
When a banner is created the banner ID, banner path and banner content type are added to Redis in seperate hash keys. The banner path and banner content type can be found by the banner ID as key. The banner ID can be found in the campaign alongside the other associated banner IDs by the Campaign ID as key.
Because the banner can be updated I do an 'after_save' callback instead of an 'after_create' callback. Therefore the banneer ID needs to be deleted first, to overcome that the banner ID is added too much times.
Note that the banner ID is added 'x' times, where x is equal to the weight. This is necessary to retrieve the next banner for a weighted  request.

###Deleting a banner
When a banner is deleted, the banner path and banner content type are removed from Redis as well as the banner ID is removed from the campaign in Redis. 

##Pitfalls and progression during development
I started with a Rails app, because I'm most familiar to Rails.
To get a better performing app, using benchmarking I made the following progression:
* Substitute Redis list for a Redis has_key
* Using thin webserver
* Eliminating all queries in the frontend
* Migration to Sinatra
* Stripping off more libraries
Sadly I forgot to write down the benchmark results between the steps.

###Substitute Redis list for a Redis has_key
Using a Redis list for the banner IDs to be stored in Redis for the campaign looks to be straight forward. When I benchmarked it, it was about as fast as retrieving the banner IDs from the database. So the Redis list was incredible slow.
Instead of using a Redis list, I tried a Redis hash key, where the key is the campaign ID and the value all the banner IDs converted to a string. This was about ten times faster then a Redis list. See also http://redis.io/topics/data-types and http://redis.io/topics/memory-optimization for more information.
I have included a benchmark for it in the file 'benchmarks/get_banner_ids_from_redis.rb'
After 'fixing' this pitfall, the app reached about 5.000 requests per minute
See the section 'benchmarking' for the current benchmark results.

###Using thin webserver
Using the thin-webserver instead of WEBrick. After 'fixing' this pitfall the app reaches about 7.500 requests per minute

###Eliminating all queries in the frontend
To eliminate all the queries in the frontend, the last step was to substitue the method 'Campaign#find' for 'Campaign#find_from_redis_by_id'.
Substitute the method 'Campaign#find' for 'Campaign.find_from_redis_by_id' didn't have any performance improvements. That's maybe because I add different keys for every attribute in Redis. Adding just one key to Redis and put every attribute in that key, may
probably result in a performance improvement. Because of a lack of time I didn't test it. 
The downside of adding just one key in Redis with all attributes in it, is that it could make the code harder to read and to maintain.

Using Redis instead of the database, relieves the database. So there are more resources available for the database. These resources can
be used for other purposes.
Please note that if you use Redis the wrong way (e.g. using a large list instead of a single hash entry), it can be even slower then your
database.

After fixing this pitfall, sadly the app still reaches about 7.5000 requests per minute

###Migration to Sinatra
After migrating the app to Sinatra, the app reaches about 9.500 requests per minute using 'rackup.
See the section 'benchmarking' for the current benchmark results.

### Stripping off more libraries
Because of a lack of time I was not able to substitute ActiveRecord for Sequel and create plain Ruby scripts where possible.
Hopefully if I had the time I could reach over 10.000 requests per minute.

##Limitations / TODO's
* To speed up the application, please strip off ActiveRecord and implement Sequel
* Use plain Ruby scripts where possible. So for example extract functions from the model that does not depend on the model itself.
* Add just one key to Redis and put every attribute in that key, instead of a key for every attribute
* Move the common denominator used in the request to the Campaign model as attribute.
* 'Banner_ids_left' and the current request-ratio are stored in the session. This is a lot of data in the session, but it looks to be the only solution. Using Rack:Session:Pool is about as fast as storing it in a cookie, so I've chosen to use Rack:Session:Pool
* Because of limited time, I skipped creating a very user friendly admin GUI with a slider for the ratio and a multiple file uploader to upload the images
* Because of limited time, I used Heroku for deployment, so no Capistrano script is added for deployment.
* For selecting a banner, native Ruby functions are used. These functions are mostly known as 'not so fast'. The cumulative density function might be the fastest way to select a banner or by using a hash to determine which banner ids are left. Unfortunately I did not have the time to impement it.
* If I can use a hash to determine which banners are already 'seen' instead of which banner ids are left, there is less space needed in the session for all ids
* Use RubyProfiler for benchmarking
* I forgot to write down benchmark results with results during the progression I made.
* Use another library besides 'Curb', because it looks to be that 'Curb' does not set a session. So for every request in the benchmark, a new session is created.
* For simplicity, the admin-interface uses HTTP authentication basic for logging in. It is pretty unsafe, but OK for now, I think.
* HTTP authentication is disabled in the test-environment, because Capybara can't handle it.
* This application uses Selenium for testing with Capybara. I would like to use a more lightweight library, but I couldn't get it to work. After two hours trying to install another library, I decided to use Selenium.
* Substitute 'Dir.pwd' for 'settings.root'
* Create a Rake Task to 'refill' Redis. Useful e.g. if Redis is flushed.
* Eliminate warning 'I18n.enforce_available_locales will default to true in the future. If you really want to skip validation of your locale you can set I18n.enforce_available_locales = false to avoid this message.'


##Additional notes
###Decsion for using Sinatra
Please note that the admin-interface is also integrated in the Sinatra app.
In practice it might be a good option to develop the admin-interface in a seperate Rails-app. Considering the costs I think developing the admin-interface in Rails is much more efficient then developing it in Sinatra. In other words, I think Rails is a better sollution for more 'straight-forward' applications (like an admin-interface) where you do not need 'high-performance'.
Another option might be using Padrino for managing the data. In that case I also need a seperate app.
A third option might be to 'mix' Rails or Padrino with Sinatra into one app. Trying to mix Rails or Padrino with Sinatra to keep everything in one app sounds to me as the worst idea, so that is not an option.

I decided that for this test it is better to develop just one app, especially, because I need to deploy it to Heroku. Deploying two apps to Heroku using one database looks to be a little tricky. I don't want to take the risk that I developed two seperate apps and I got stuck on deploying it to Heroku. See also: http://stackoverflow.com/questions/5981508/share-database-between-2-apps-in-heroku. To keep everything into one app I decided to develop the admin-interface in the Sinatra-app and not as a seperate Rails or Padrino app. 

Another downside is because of a before-hook to determine whether HTTP authentication is needed, the frontend may slow down a little bit. It's just a little bit, but I see it as another downside of intergrating the admin-interface in the app.

In practice I prefer to develop two seperate apps:
- a Sinatra app for the frontend
- a Rails app for the backend (admin)
In my opinion it is a really a downside that I had to develop the admin-interface in Sinatra as well. In my opinion Sinatra isn't suiteable to create an admin-interface. Nonetheless it was the best idea when taken into account that deploying two apps to Heroku might be tricky.

###A very basic admin-interface
Mike adviced me that I didn't had to focus too much on the admin-interface. I followed his advice to save up some time. The downside is that the admin-interface isn't very userfriendly, e.g. a multuple file uploader is missing. You have to upload each banner seperately. Resizing and cropping the banner-image isn't even available.
The most important thing in my opinion is that the admin-interface at least has RESTfull-routes.

###HTML Helpers
Because Sinatra doesn't have any HTML helpers available by default, I don't use any HTML Helpers in the view. I use the HAML DSL in the views.

###400 test banners included
For developing purposes 400 test banners are included in this application, so you can easily seed the database. You can find them in the path 'db/fixtures/images'. In reality, this is quiet an ugly solution to include the images in the fixures directory.

###Usage of Redis
However Memcache might be a more accepted solution, I used Redis, because I'm more familiar to Redis..

###Deploying to Heroku
Please note that a 'heroku' branch is added to Github to deploy to Heroku. This is because Heroku may require some specific configurations. For example my Gemfile.lock contains the gem 'railties 4.0/4'. This means that Heroku will start a Rails server, which will not work. So in the Heroku branch I deleted the Gemfile.lock. See also: https://devcenter.heroku.com/articles/ruby-support#rails-4-x-applications

In practice I prefer to setup my own VPS. The benefit of your own VPS is in my opinion that you have full control. The downside of your own VPS is that the first deployment may take some time, because you have to establish the VPS and write your own capistrano-script before you can deploy.
On Heroku you don't have full-control on the server, but deploying for the first time is in most cases easier. So due to a lack of time and the simplicity of Heroku I used Heroku in this case.

##Testing with Rspec
Application tested using Rspec and Ruby 2.0.0p247
Please note the following:
* The test coverage of the function '.get_banner_and_requests_made(requests_made_and_banners_seen)' may not always return the right test results. In rare cases, the weighted request might return different values then expected.
* Please note that the tests can be relatively slow, because all images will be added when creating a campaign.

##Known bugs
* When running the following command
```
rspec
````
Some test may fail when running the command 'rspec' and need to be runned standalone. At this moment the following test need to be runned standalone:
```
spec/requests/login_spec.rb:9
```

* The Rspec test displays all the queries, which gives a bad overview. This setting seems not to work:
```
set :logging, false
```
* If you have installed activerecord-4.1.0, probably the following command will not work:
```
rake db:seed
```
Please uninstall activerecord-4.1.0 to proceed.
* HTTP authentication disabled in the test-environment, because Capybara cannot handle it.

##Benchmarking
Please note that only the benchmarks of the current app are written down. I forgot to write down interim results.

Alll the benchmarks lives in the following directory 
```
benchmarks/
````
For the requests I use the gem 'curb', becuase it is super fast as said in the conclusion of this article: http://bibwild.wordpress.com/2012/04/30/ruby-http-performance-shootout-redux/.

Sadly I didn't have the time to benchmark with another library besides 'Curb'. At each request, Curb starts a new session and I would like to benchmark it with a library that holds the session for each request.

###Requests
Results for 10.000 requests made (see also benchmarks/requests.rb).
Dump from Benchmark.measure:
````
#<Benchmark::Tms:0x007fb6eb133928 @label="", @real=62.972004, @cstime=0.0, @cutime=0.0, @stime=0.65, @utime=1.6500000000000001, @total=2.3000000000000003>
```

Resuls from getting 5.000 times 400 banner IDs from Redis.
Dump from Benchmark.measure:
````
#<Benchmark::Tms:0x007fe90a979690 @label="", @real=3.016043, @cstime=0.0, @cutime=0.0, @stime=0.32999999999999996, @utime=2.4299999999999997, @total=2.76>
```
Sadly I didn't have the time to implement RubyProfiler. Using Benmark.measure gives a very basic overview of the benchmark results.
