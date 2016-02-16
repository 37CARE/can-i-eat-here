source 'https://rubygems.org'

ruby "2.2.4"

gem 'sinatra'
gem 'data_mapper'
gem 'bcrypt'
gem 'graticule'
gem 'rake'
# Rake is a tool for running 1 off commands

group :development do
  gem 'sqlite3'
  gem 'rerun'
  gem 'dm-sqlite-adapter'
  gem 'dotenv'
end


group :production do
  gem 'dm-postgres-adapter'
  gem 'pg'
end
