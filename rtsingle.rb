#!/usr/local/bin/ruby

# RTsingle - ReTweet a single account to your twitter feed.  Uses oldschool RT @user.
$:.unshift "."

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

def charlimiter(text_in)
  if text_in.length > 140
    if !!text_in[" http://"] # lets not damage the links in the retweets!
      str_spl = text_in.split(" http://")
      str_spl[0] = str_spl[0][0..str_spl[0].length-text_in.length+135] + "..."
      return str_spl.join(" http://")
    else
      return (text_in[0..136] + '...')
    end
  else
    return text_in[0..139]
  end
end

my_tweets = Array.new

to_self.each do |object| # get your own tweets for the last 24 hours
    if ((object.created_at - Time.now).to_i / (24 * 60 * 60) + 1) == 0
		my_tweets.push(object.text) if object.is_a?(Twitter::Tweet)
    end
end

to_retweet.each do |object| # tweets of last 24 hours are retweeted with no duplicates
    if ((object.created_at - Time.now).to_i / (24 * 60 * 60) + 1) == 0
		if object.is_a?(Twitter::Tweet) and not object.retweet? and not my_tweets.include?(charlimiter("RT @#{RT_ACCOUNT} " + object.text))
			client.update(charlimiter("RT @#{RT_ACCOUNT} " + object.text))
		end
    end
end
