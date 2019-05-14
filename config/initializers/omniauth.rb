use OmniAuth::Builder do
    provider :vimeo, ENV['VIMEO_ACCESS_KEY'], ENV['VIMEO_CLIENT_SECRET']
end
