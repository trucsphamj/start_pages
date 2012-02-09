require 'sinatra'
require 'redis'

r = Redis.new
#r.flushdb

$suggestedLinks = {"http://www.bankofamerica.com" => "Bank Of America", "http://www.fullerton.edu" => "Cal State Fulllerton", 
"http://www.youtube.com" => "YouTube", "http://www.facebook.com" => "Facebook", "http://csuf.kenytt.net" => "Web Programming CPSC 473, CSU Fullerton",
"http://www.frys.com" => "Frys Electronic", "http://www.nasa.com" => "NASA", "http://www.ruby-doc.org/core-1.9.3/" => "Ruby API",
"http://redis.io/commands" => "Redis API"}


$sitesHash = {}
$toBeDeletedLinksHash = {}

get '/' do
   erb :test1
end

post '/register' do
   erb :register
end

get '/edit' do
     erb :edit
end

post '/addURL' do
   @hiddenURL = params[:hiddenURL]
   @url = params[:myURL]
   @siteName = params[:siteName]

   if((@hiddenURL != nil) && (@url == nil))
   	r.hsetnx 'favoriteURLs',@hiddenURL, @siteName 
	r.hsetnx 'toBeDeletedLinks', @hiddenURL, @siteName
	$suggestedLinks.delete(@hiddenURL)
   else
       r.hsetnx 'favoriteURLs', @url, @siteName
	r.hsetnx 'toBeDeletedLinks', @url, @siteName
   end

   $toBeDeletedLinksHash = r.hgetall 'toBeDeletedLinks'
   redirect '/edit'
end

post '/removeURL' do
   @hiddenURL = params[:hiddenURL]
   @siteName = params[:siteName]
   $suggestedLinks[@hiddenURL] = @siteName
   r.hdel 'favoriteURLs', @hiddenURL
   r.hdel 'toBeDeletedLinks', @hiddenURL
   $toBeDeletedLinksHash = r.hgetall 'toBeDeletedLinks'
   redirect '/edit'
end

get '/mySites' do
   $sitesHash = r.hgetall 'favoriteURLs'
   erb :displaySites
end