require 'sinatra'
require_relative 'models'

enable :sessions

get "/" do
  erb :home
end

get "/users/new" do
  @user = User.new
  erb :new_user
end

post "/users" do
  @user = User.create(params[:user])
  if @user.saved?
    redirect "/"
  else
    erb :new_user
  end
end

get "/sessions/new" do
  @login_attempt = User.new
  erb :new_session
end

post "/sessions" do
  @login_attempt = User.first({ :email => params[:user]["email"] })

  if @login_attempt && @login_attempt.password == params[:user]["password"]
    session[:current_user] = @login_attempt.id
    redirect "/"
  else
    @login_attempt = User.new
    @login_attempt.errors.add(:password, "Couldn't find a user with that email/password combination")
    erb :new_session
  end
end
