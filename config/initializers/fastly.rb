# typed: false

CLOUDFRONT_API = Rails.application.config.services.cloudfront
proxy_list = []

begin
  puts "⬇️  Pulling trusted_proxies list from Cloudfront"
  response = Faraday.get(CLOUDFRONT_API)
  list = JSON.parse(response.body)
  proxy_list = list.dig("CLOUDFRONT_GLOBAL_IP_LIST")
rescue => e
  puts "Failed to load trusted_proxies from Cloudfront. Error: #{e.message}"
end

Rails.application.config.action_dispatch.trusted_proxies = proxy_list.map { |proxy| IPAddr.new(proxy) }
puts "✅ Set trusted_proxies list"
