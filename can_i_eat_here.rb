require 'sinatra'
require_relative 'models'

enable :sessions
# Docs: http://www.sinatrarb.com/faq.html#sessions


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
  # First, we try and find a user who actually matches that email address
  @login_attempt = User.first({ :email => params[:user]["email"] })

  # Then, we check if that users password matches the inputted password
  if @login_attempt && @login_attempt.password == params[:user]["password"]

    # If it does, we store the users ID in the `session` hash
    session[:current_user] = @login_attempt.id

    # And we send them back to the home page, since they're all logged in!
    redirect "/"
  else
    # If we didn't find a user, or the password was wrong...

    # "Instantiate" a user that isn't in the database
    @login_attempt = User.new

    # Stick some errors in it so we can let the person know what was up.
    @login_attempt.errors.add(:password, "Couldn't find a user with that email/password combination")

    # Then re-render that view!
    erb :new_session
  end
end
