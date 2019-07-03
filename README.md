# Speedcurve

- Gem to set off speed curve after a new deployment

## Add to your project:

Add the following to your project Gemfile

~~~
gem 'capistrano-speedcurve', :git => 'git@github.com:Skywire/capistrano-speedcurve.git', :branch => 'master'
~~~

Then run 

~~~
bundle install
~~~

Add the following to your project Capfile

~~~
require "capistrano/speedcurve"
~~~

## Configuration

Add the speed curve API key to the product staging only:

~~~
set :speedcurve_api_key, "api_key"
set :speedcurve_site_id, "site_id"
~~~

Details are here on the deploys API: https://api.speedcurve.com/#add-a-deploy