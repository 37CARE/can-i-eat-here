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
end

class Restriction
  include DataMapper::Resource

  property :id, Serial
  property :name, String, { :required => true }

  belongs_to :creator, 'User'
end

DataMapper.finalize
DataMapper.auto_upgrade!
