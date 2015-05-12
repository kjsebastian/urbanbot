require "twitter"
require "./config.rb"

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = Settings.CONSUMER_KEY
  config.consumer_secret     = Settings.CONSUMER_SECRET
  config.access_token        = Settings.ACCESS_TOKEN
  config.access_token_secret = Settings.ACCESS_SECRET
end

rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = Settings.CONSUMER_KEY
  config.consumer_secret     = Settings.CONSUMER_SECRET
  config.access_token        = Settings.ACCESS_TOKEN
  config.access_token_secret = Settings.ACCESS_SECRET
end

rest_client.update("@_kjsebastian hello", in_reply_to_status_id: "598027760435474432")

client.user do |object|
  case object
  when Twitter::Tweet
    puts "Tweet"
    puts object.in_reply_to_screen_name
    puts object.in_reply_to_user_id
    puts object.user_mentions[0].name
    puts object.uri
  end
end
