require 'data_mapper'
require 'bcrypt'

DataMapper.setup(:default, ENV['DATABASE_URL'])

class User
  include DataMapper::Resource

  property :id, Serial
  property :name, String,  { :required => true }
  property :email, String, { :required => true,
                             :unique => true,
                             :format => :email_address }
  property :password, Text

  has n, :restaurants, { :child_key => [:creator_id] }
  has n, :created_restrictions, "Restriction", { :child_key => [:creator_id] }

  def password=(password)
    self.attribute_set(:password, BCrypt::Password.create(password))
  end

  def password
    BCrypt::Password.new(self.attribute_get(:password))
  end
end

class Restaurant
  include DataMapper::Resource

  property :id, Serial
  property :name, String, { :required => true }
  property :address, Text, { :required => true }

  belongs_to :creator, 'User'

  has n, :restaurants_restrictions
  has n, :supported_restrictions, "Restriction", { :through => :restaurants_restrictions }
  # Here we're defining a "has many through" relationship. In order to do that,
  # we need:
  # 1 association to a "linking" table (`has n, :restaurants_restrictions`)
  # 1 assocation to the supported_restrictions. This goes `through` the
  # `restaurants_restrictions` association.

  def add_supported_restriction(restriction)
    # I don't want toe xpose the `restaurants_restrictions` to the views or
    # routes, so I added a little helper to this model

    self.restaurants_restrictions.first_or_create(:supported_restriction => restriction)
    # The helper says:
    #  * Get me my restaurant_restrictions
    #  * Find one with the passed in restriction as its supported_restriction
    #  * *otherwise* create a restaurant_restriction with the given restriction
  end
end

class RestaurantsRestriction
  include DataMapper::Resource

  property :id, Serial

  belongs_to :supported_restriction, "Restriction"
  belongs_to :restaurant
end
# Here we're creating a database model expressly for connecting a restaurant to
# a supported restriction. This can be a tough concept to grok, since we don't
# really have stuff like this in real life.

class Restriction
  include DataMapper::Resource

  property :id, Serial
  property :name, String, { :required => true }

  belongs_to :creator, 'User'
end

DataMapper.finalize
DataMapper.auto_upgrade!
