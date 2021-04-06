require './app'
require './middleware/rackmiddleware'  
use Rack::Session::Cookie 
use Chat::ChatMiddleware
run App
