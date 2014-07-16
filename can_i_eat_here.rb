require 'sinatra'
require_relative 'models'

get "/" do
  erb :home
end
