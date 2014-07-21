require_relative 'config/dotenv'
require_relative 'models'


task :refresh_geolocations do
# We can run this task locally with `rake refresh_geolocations`
# or we can run it on heroku with `heroku run rake refresh_geolocations`
  Restaurant.all.each do |restaurant|
    restaurant.refresh_geolocation!
  end
end
