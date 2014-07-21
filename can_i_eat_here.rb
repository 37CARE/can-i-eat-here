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

  def ensure_logged_in!
    unless logged_in?
      halt 403, "You must be logged in to do that!"
    end
  end
end

get "/" do
  @restaurants = Restaurant.search(params["query"])
  erb :home
end

#
# USERS
#
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

#
# RESTAURANTS
#
get "/restaurants/new" do
  ensure_logged_in!
  @restaurant = current_user.restaurants.new
  erb :new_restaurant
end

post "/restaurants" do
  ensure_logged_in!
  @restaurant = current_user.restaurants.create(params["restaurant"])
  if @restaurant.saved?
    @restaurant.refresh_geolocation!
    redirect "/"
  else
    erb :new_restaurant
  end
end

get "/restaurants/:restaurant_id/supported_restrictions/new" do
  ensure_logged_in!
  @restaurant = Restaurant.get(params["restaurant_id"])
  @available_restrictions = Restriction.all
  erb :restaurants_new_supported_restriction
end

post "/restaurants/:restaurant_id/supported_restrictions" do
  ensure_logged_in!
  restaurant = Restaurant.get(params["restaurant_id"])
  restriction = Restriction.get(params["supported_restriction"]["id"])

  restaurant.add_supported_restriction(restriction)

  redirect "/"
end

#
# RESTRICTIONS
#
get "/restrictions/new" do
  @restriction = Restriction.new
  erb :new_restriction
end

post "/restrictions" do
  ensure_logged_in!
  @restriction = current_user.created_restrictions.create(params["restriction"])
  if @restriction.saved?
    redirect "/"
  else
    erb :new_restriction
  end
end


#
# SESSION
#
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
