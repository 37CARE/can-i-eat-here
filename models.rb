require 'data_mapper'

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
end

DataMapper.finalize
DataMapper.auto_upgrade!
