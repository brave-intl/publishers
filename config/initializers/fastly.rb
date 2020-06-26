FASTLY_API = Rails.application.config.services.fastly
proxy_list = []

begin
  puts "⬇️  Pulling trusted_proxies list from Fastly"
  response = Faraday.get(FASTLY_API)
  list = JSON.parse(response.body)
  proxy_list = list.dig("addresses")
rescue StandardError => e
  puts "Failed to load trusted_proxies from Fastly. Error: #{e.message}"
end

Rails.application.config.action_dispatch.trusted_proxies = proxy_list.map { |proxy| IPAddr.new(proxy) }
puts "✅ Set trusted_proxies list"
