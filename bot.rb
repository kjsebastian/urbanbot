require "twitter"
require "./config.rb"

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = Settings.CONSUMER_KEY
  config.consumer_secret     = Settings.CONSUMER_SECRET
  config.access_token        = Settings.ACCESS_TOKEN
  config.access_token_secret = Settings.ACCESS_SECRET
end

client.update("tweet from ruby!")