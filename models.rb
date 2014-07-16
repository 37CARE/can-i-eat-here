require 'data_mapper'
require 'bcrypt'

if ENV['RACK_ENV'] != 'production' 
  require 'dotenv'
  Dotenv.load('.env')
end


DataMapper.setup(:default, ENV['DATABASE_URL'])

class User
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :email, String
  property :password, String

  def password=(password)
    self.attribute_set(:password, BCrypt::Password.create(password))
  end

  def password
    BCrypt::Password.new(self.attribute_get(:password))
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!
