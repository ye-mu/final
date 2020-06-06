# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "geocoder"                                                                    #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

restaurants_table = DB.from(:restaurants)
comments_table = DB.from(:comments)
users_table = DB.from(:users)

before do
    @current_user = users_table.where(:id => session[:user_id]).to_a[0]
    puts @current_user.inspect
end

get "/" do
    @restaurants = restaurants_table.all
    puts @restaurants.inspect
    view "restaurants"
end

get "/restaurants/:id" do
    @users_table = users_table
    @restaurant = restaurants_table.where(:id => params["id"]).to_a[0]
    @comments = comments_table.where(:restaurant_id => params["id"]).to_a
    @count = comments_table.where(:restaurant_id => params["id"], :recommended => true).count
    puts @restaurant.inspect
    puts @comment.inspect
    view "restaurant"
end

get "/restaurants/:id/comments/new" do
    @restaurant = restaurants_table.where(:id => params["id"]).to_a[0]
    puts @restaurant.inspect
    view "new_comment"
end

post "/restaurants/:id/comments/create" do
    puts params.inspect
    comments_table.insert(:restaurant_id => params["id"],
                       :recommended => params["recommended"],
                       :user_id => @current_user[:id],
                       :comments => params["comments"])
    @restaurant = restaurants_table.where(:id => params["id"]).to_a[0]
    view "create_comment"
end

get "/users/new" do
    view "new_user"
end

post "/users/create" do
    puts params.inspect
    users_table.insert(:name => params["name"],
                       :email => params["email"],
                       :password => BCrypt::Password.create(params["password"]))
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    puts params
    email_entered = params["email"]
    password_entered = params["password"]
    user = users_table.where(:email => email_entered).to_a[0]
    if user
        puts user.inspect
        if BCrypt::Password.new(user[:password]) == password_entered
            session[:user_id] = user[:id]
            view "create_login"
        else
            view "create_login_failed"
        end
    else 
        view "create_login_failed"
    end
end

get "/logout" do
    session[:user_id] = nil
    view "logout"
end