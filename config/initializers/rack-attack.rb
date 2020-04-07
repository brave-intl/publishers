class Rack::Attack

  # Safelists
  if Rails.application.secrets[:api_ip_whitelist]
    API_IP_WHITELIST = Rails.application.secrets[:api_ip_whitelist].split(",").freeze
  else
    API_IP_WHITELIST = [].freeze
  end

  safelist('allow/API_IP_WHITELIST') do |req|
    # Requests are allowed if the return value is truthy
    API_IP_WHITELIST.include?(req.ip)
  end

  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blacklisting and
  # whitelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip if !req.path.start_with?("/assets")
  end

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
  throttle("logins/ip", limit: 5, period: 120.seconds) do |req|
    if req.path.start_with?("/publishers/") && req.params["token"]
      req.ip
    end
  end

  throttle("uphold/login", limit: 5, period: 10.minutes) do |req|
    if req.path.start_with?("/uphold/login")
      req.ip
    end
  end

  throttle("2fa_sign_in", limit: 10, period: 15.minutes) do |req|
    if req.path.start_with?("/publishers/two_factor_authentications")
      req.ip
    end
  end

  # Throttle resend auth emails for a publisher
  throttle("resend_authentication_email/publisher_id", limit: 20, period: 20.minutes) do |req|
    if req.path == "/publishers/resend_authentication_email" && req.post?
      req['publisher_id']
    end
  end

  # Throttle send 2fa disable emails for an IP address
  throttle("request_two_factor_authentication_removal/publisher_id", limit: 2, period: 24.hours) do |req|
    if req.path == "/publishers/request_two_factor_authentication_removal" && req.post?
      req.ip
    end
  end

  # Throttle confirm 2fa disable emails for an IP address
  throttle("confirm_two_factor_authentication_removal/publisher_id", limit: 2, period: 24.hours) do |req|
    if req.path == "/publishers/confirm_two_factor_authentication_removal" && req.get?
      req.ip
    end
  end

  # Throttle cancel 2fa disable emails for an IP address
  throttle("cancel_two_factor_authentication_removal/publisher_id", limit: 2, period: 24.hours) do |req|
    if req.path == "/publishers/cancel_two_factor_authentication_removal" && req.get?
      req.ip
    end
  end

  # Throttle POST requests to /login by email param
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that"s not very common and shouldn"t happen to you. (Knock
  # on wood!)
  # throttle("logins/email", :limit => 5, :period => 20.seconds) do |req|
  #   if req.path.start_with?("/publishers/") && req.params["token"]
      # return the email if present, nil otherwise
  #     req.params["email"].presence
  #   end
  # end

  throttle("registrations/create", limit: 10, period: 1.hour) do |req|
    if (req.path.starts_with?("/publishers/registrations") ||
        req.path.starts_with?("/publishers/resend_authentication_email")
        ) && (req.post? || req.patch? || req.put?)
      req.ip
    end
  end

  if Rails.env.production?
    # Throttle requests to public api, /api/public
    throttle("public-api-request/ip", limit: 5, period: 1.hour) do |req|
      req.ip if ["/api/v1/public", "api/v2/public", "api/v3/public"].any? { |endpoint| req.path.start_with?(endpoint) }
    end
  else
    throttle("public-api-request/ip", limit: 60, period: 1.hour) do |req|
      req.ip if ["/api/v1/public", "api/v2/public", "api/v3/public"].any? { |endpoint| req.path.start_with?(endpoint) }
    end
  end

  ### Custom Throttle Response ###
  self.throttled_response = lambda do |env|
    [
      420, # status
      {"Content-Type" => "text/plain; charset=UTF-8"}, # headers
      ["🎷 Try again in a bit"] # body
    ]
  end
end
