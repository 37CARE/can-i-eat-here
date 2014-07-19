require 'sinatra'
require_relative 'models'

get "/" do
  erb :home, { :layout => :default_layout }
end

get "/users/new" do
  @user = User.new
  erb :new_user, { :layout => :default_layout }

end
post "/users" do
  @user = User.create(params[:user])
  if @user.saved?
    redirect "/"
  else
    raise @user.errors.inspect
    # This is just temporary. We will handle errors more gracefully soon. I
    # just wanted a way to see errors if a user can't sign up.
  end
end
