require 'data_mapper'
require 'graticule'
require 'bcrypt'

DataMapper.setup(:default, ENV['DATABASE_URL'])

class User
  include DataMapper::Resource

  property :id, Serial
  property :name, String,  { :required => true }
  property :email, String, { :required => true,
                             :unique => true,
                             :format => :email_address }
  property :password, BCryptHash

  has n, :restaurants, { :child_key => [:creator_id] }
  has n, :created_restrictions, "Restriction", { :child_key => [:creator_id] }
end

class Restaurant
  SEARCH_RADIUS = 10
  include DataMapper::Resource

  property :id, Serial
  property :name, String, { :required => true }
  property :address, Text, { :required => true }
  property :latitude, Float
  property :longitude, Float

  belongs_to :creator, 'User'

  has n, :restaurants_restrictions
  has n, :supported_restrictions, "Restriction", { :through => :restaurants_restrictions }

  def add_supported_restriction(restriction)
    self.restaurants_restrictions.first_or_create(:supported_restriction => restriction)
  end

  def self.search(query, options={})

    restaurants = all(:name.like => "%#{query}%") |
      all(supported_restrictions.name.like => "%#{query}%") |
      all(:address.like => "%#{query}%")

    return restaurants unless options[:near]

    location = geocoder.locate(options[:near])
    # We geocode the input the user gave us so we can compare distances

    restaurants.select do |restaurant|
      restaurant.near?(location)
    end
    # `select` is a way to filter down a collection so it only includes things
    # that evaluate to true within the block. Here it's saying "Only include
    # restaurants whose `near` method returns true when passed the location
    # someone searched for"
  end

  def near?(other_location)
    self.location.distance_to(other_location) <= SEARCH_RADIUS
  end

  def refresh_geolocation!
    location = geocoder.locate(address)
    self.latitude = location.latitude
    self.longitude = location.longitude
    self.save
  end

  def location
    @location ||= Graticule::Location.new({ latitude: self.latitude, longitude: self.longitude })
  end

  def geocoder
    self.class.geocoder
  end

  def self.geocoder
    @@geocoder ||= Graticule.service(:google).new ENV['GOOGLE_GEOCODER_API_KEY']
  end
end

class RestaurantsRestriction
  include DataMapper::Resource

  property :id, Serial

  belongs_to :supported_restriction, "Restriction"
  belongs_to :restaurant
end

class Restriction
  include DataMapper::Resource

  property :id, Serial
  property :name, String, { :required => true }

  belongs_to :creator, 'User'
end

DataMapper.finalize
DataMapper.auto_upgrade!
