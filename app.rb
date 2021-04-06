require 'sinatra'
require 'sinatra/cookies'
require 'digest'
require 'securerandom'
require 'sinatra/base'
require 'mongo'

class App  < Sinatra::Base

enable :sessions
helpers Sinatra::Cookies
use Rack::Session::Cookie
client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'local')
db = client.database

# configure do
#   set :public_folder, File.expand_path('../public', __FILE__)
#   set :views, File.expand_path('../views', __FILE__)
#   set :root, File.dirname(__FILE__)
#   set :show_exceptions, development?
# end
# set :views,  '../views'
# set :public_folder, '../public'

# sets root as the parent-directory of the current file
#set :root, File.join(File.dirname(__FILE__), '..')
# set :root, '../'
# sets the view directory correctly
# set :views, Proc.new { File.join(root, "views") } 


get "/" do
  collections = db.collection_names
  print "Hello, Frank, the collections are "+collections.to_s
  erb :index
end


post "/login" do 
  username = params[:username]
  password = params[:password]
  myCollection = client[:myCollection]
  user = myCollection.find({"username":username}).first
  if user
    print(password,user[:password])
    if user[:password].eql? password 
      createSession(user)
      setCookie("cookie",user[:username],Date.new(2022,10,10))
      cookies[:username] = user[:username]
      redirect('/main')  
    else
      puts "Here1"
      redirect('/unauthorised')
    end

  else
    puts "Here2"
    redirect('/unauthorised')
  end
end


get "/main" do
  authenticateRequest()
  puts "I've got you, under my session "+session[:username]+" Here have a cookie "+cookies[:username]
  erb :main
end



get "/logout" do
  if value = cookies[:cookie]
    cookies.delete(:cookie)
    redirect('/')
    session.clear
  else
    redirect('/unauthorised')
  end
end

get "/unauthorised" do
  "Sorry! No access for you."
end


####Helper Methods########

def createSession(user)
  session[:username] = user[:username]
end

def authenticateRequest()
  puts cookies[:cookie] 
  if cookies[:cookie]
    #proceed
    if session[:username]
      return
    else
      session[:username] = cookies[:cookie]
    end 
  else
    puts "Here3"
    redirect('/unauthorised')
  end
end

def setCookie(key,value,expires)
  response.set_cookie(key, :value => value,
                        :domain => "",
                        :expires => expires)
end
  

end

   
