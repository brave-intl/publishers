use OmniAuth::Builder do
  provider :vimeo, ENV['VIMEO_ACCESS_KEY'], ENV['VIMEO_CLIENT_SECRET']
  provider :reddit, ENV['REDDIT_ACCESS_KEY'], ENV['REDDIT_CLIENT_SECRET']
end
