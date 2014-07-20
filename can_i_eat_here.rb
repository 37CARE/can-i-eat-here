require 'sinatra'
require_relative 'config/dotenv'
require_relative 'config/session'
require_relative 'models'

helpers do
  def current_user
    @current_user ||= User.get(session[:current_user])
  end

  def login(user)
    @current_user = user
    session[:current_user] = user.id
    redirect "/"
  end

  def logged_in?
    !session[:current_user].nil?
  end
end

get "/" do
  @restaurants = Restaurant.all
  erb :home
end

get "/users/new" do
  @user = User.new
  erb :new_user
end

post "/users" do
  @user = User.create(params[:user])
  if @user.saved?
    login(@user)
  else
    erb :new_user
  end
end

get "/restaurants/new" do
  @restaurant = current_user.restaurants.new
  erb :new_restaurant
end

post "/restaurants" do
  @restaurant = current_user.restaurants.create(params["restaurant"])
  if @restaurant.saved?
    redirect "/"
  else
    erb :new_restaurant
  end
end

get "/session/new" do
  @login_attempt = User.new
  erb :new_session
end

post "/session" do
  @login_attempt = User.first({ :email => params[:user]["email"] })

  if @login_attempt && @login_attempt.password == params[:user]["password"]
    login(@login_attempt)
  else
    @login_attempt = User.new
    @login_attempt.errors.add(:password, "Couldn't find a user with that email/password combination")
    erb :new_session
  end
end

delete "/session" do
  session.delete(:current_user)
  redirect "/"
end
