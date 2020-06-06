# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :restaurants do
  primary_key :id
  String :name
  String :location
  String :description, text: true
  end

DB.create_table! :comments do
  primary_key :id
  foreign_key :restaurant_id
  Boolean :recommended
  String :name
  String :email
  String :comments, text: true
end

DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

restaurants_table = DB.from(:restaurants)

restaurants_table.insert(name: "KFC", 
                        location: "Beijing",
                        description: "Yummy and cheap")

