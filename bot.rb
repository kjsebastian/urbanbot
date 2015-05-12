require "twitter"
require "net/http"
require "json"
# Modify config_sample.rb with proper variables
require "./config.rb"

# Initialize clients
# Streaming client to monitor incoming streams
client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = Settings.CONSUMER_KEY
  config.consumer_secret     = Settings.CONSUMER_SECRET
  config.access_token        = Settings.ACCESS_TOKEN
  config.access_token_secret = Settings.ACCESS_SECRET
end

# Rest client to update status using rest api
rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = Settings.CONSUMER_KEY
  config.consumer_secret     = Settings.CONSUMER_SECRET
  config.access_token        = Settings.ACCESS_TOKEN
  config.access_token_secret = Settings.ACCESS_SECRET
end

# Parse the tweet uri (Addressable::URI) to get the user and tweet id
def parse_tweet_uri(uri)
  uri_elements = uri.path.split("/")
  user_screen_name = uri_elements[1]
  tweet_id = uri_elements.last
  puts user_screen_name, tweet_id

  return user_screen_name, tweet_id
end

def check_tweet(text)
  return text.include? "define"
end

# Return which word to define
def get_word_to_define(text)
  return text[/define \w+/].split(" ").last
end

# Get the definition from Urban Dictionary API
def urban_define(word)
  api_url = "http://api.urbandictionary.com/v0/define?term=#{word}"
  res = Net::HTTP.get_response(URI.parse(api_url))
  json_res = JSON.parse(res)
  definition = json_res["list"].first["definition"]
  definition = definition.split(".").first # Get the first sentence of definition
  return definition
end

# Process the tweet object retrieving necessary information
# who to reply to
# which tweet id to reply to
# check for 'define' keyword
# if keyword exists get info from urbandict api
# reply to tweet
def process(tweet)
  reply_to_user, reply_to_tweet = parse_tweet_uri(tweet.uri)
  has_define = check_tweet(tweet.text)
  if has_define
    word = get_word_to_define(tweet.text)
    definition = urban_define(word)
    reply_tweet_text = "@#{reply_to_user}, #{word} means #{definition}"
    rest_client.update(reply_tweet_text, in_reply_to_status_id: reply_to_tweet)
  else
    reply_tweet_text = "@#{reply_to_user}, I'm just a bot doing bot things. Try '@urban_bot define trollface'"
    rest_client.update(reply_tweet_text, in_reply_to_status_id: reply_to_tweet)
  end
end

# Start listening for '@' mentions
client.user do |object|
  case object
  when Twitter::Tweet
    process(object)
  end
end

