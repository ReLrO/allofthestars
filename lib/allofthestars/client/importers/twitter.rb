module AllOfTheStars::Importers::Twitter
  def import_twitter_favorites(user)
    require 'twitter'

    options    = {}
    config_key = "twitter:favorites:#{user}"
    if since_id = config(config_key)
      options[:since_id] = since_id
    end

    tweet    = Twitter.favorites(user, options).each do |tweet|
      import_tweet_status tweet
    end.first

    config(config_key, tweet.id) if tweet
  end

  def import_tweet(id)
    require 'twitter'
    import_tweet_status Twitter.status(id)
  end

  def import_tweet_status(status)
    created = Time.parse(status.created_at)
    data = {
      :type       => "Twitter",
      :content    => status.text,
      :source_url =>
        'http://twitter.com/%s/status/%s' % [
          status.user.screen_name,
          status.id],
      :custom     => {
        :id => status.id_str,
        :user => status.user.screen_name,
        :retweet_count => status.retweet_count.to_i
      },
      :created_at => created.to_i
    }

    if in_reply_name = status.in_reply_to_screen_name
      data[:custom][:in_reply_to] =
        'http://twitter.com/%s/status/%s' % [
          in_reply_name,
          status.in_reply_to_status_id_str]
    end

    add_star(data, status)
  end
end
