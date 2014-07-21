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

  def add_supported_restriction(restriction)
    self.restaurants_restrictions.first_or_create(:supported_restriction => restriction)
  end

  def self.search(query)
    all(:name.like => "%#{query}%") |
      all(supported_restrictions.name.like => "%#{query}%") |
      all(:address.like => "%#{query}%")

      # Here we're building 3 queries using symbol-based conditions , and then
      # using the "union" operator to join them different queries:
      # http://datamapper.org/docs/find.html#combining-queries
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
