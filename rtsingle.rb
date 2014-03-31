#!/usr/local/bin/ruby

require 'twitter'
require 'credentials' # put your API keys in here

client = Twitter::REST::Client.new do |config|
	config.consumer_key	= APIKEY
	config.consumer_secret	= APISECRET
	config.access_token	= ACCESSTOKEN
	config.access_token_secret = ACCESSTOKENSECRET
end

to_retweet = client.user_timeline(RT_ACCOUNT)
to_self = client.user_timeline(OWNER)

my_tweets = Array.new

def charlimiter(text_in)
	if text_in.length > 140
		return (text_in[0..136] + '...')
	end
end


to_self.each do |object|
    if ((object.created_at - Time.now).to_i / (24 * 60 * 60) + 1) == 0
		my_tweets.push(object.text) if object.is_a?(Twitter::Tweet)
    end
end

to_retweet.each do |object|
    if ((object.created_at - Time.now).to_i / (24 * 60 * 60) + 1) == 0
		if object.is_a?(Twitter::Tweet) and not object.retweet? and not my_tweets.include?(charlimiter("RT @#{RT_ACCOUNT} " + object.text))
			client.update(charlimiter("RT @#{RT_ACCOUNT} " + object.text))
		end
    end
end
