class Rack::Attack
  # Monkey-patch the request class
  # https://github.com/kickstarter/rack-attack/blob/master/lib/rack/attack/request.rb
  class Request < ::Rack::Request
    def remote_ip
      @remote_ip ||= (env['action_dispatch.remote_ip'] || ip).to_s
    end
  end

  # # Safelists
  # if Rails.application.secrets[:api_ip_whitelist]
  #   API_IP_WHITELIST = Rails.application.secrets[:api_ip_whitelist].split(",").freeze
  # else
  #   API_IP_WHITELIST = [].freeze
  # end

  # safelist('allow/API_IP_WHITELIST') do |req|
  #   # Requests are allowed if the return value is truthy
  #   API_IP_WHITELIST.include?(req.remote_ip)
  # end

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
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.remote_ip}"
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.remote_ip if !req.path.start_with?("/assets")
  end

  blocklist('fail2ban pentesters') do |req|
    # `filter` returns truthy value if request fails, or if it's from a previously banned IP
    # so the request is blocked
    Rack::Attack::Fail2Ban.filter("pentesters-#{req.remote_ip}", maxretry: 3, findtime: 1.hour, bantime: 7.days) do
      # The count for the IP is incremented if the return value is truthy
      CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
      req.path.include?('/etc/passwd') ||
      req.path.include?('wp-admin') ||
      req.path.include?('wp-login')
    end
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
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.remote_ip}"
  throttle("logins/ip", limit: 5, period: 120.seconds) do |req|
    if req.path.start_with?("/publishers/") && req.params["token"]
      req.remote_ip
    end
  end

  throttle("uphold/login", limit: 5, period: 10.minutes) do |req|
    if req.path.start_with?("/uphold/login")
      req.remote_ip
    end
  end

  throttle("2fa_sign_in", limit: 10, period: 15.minutes) do |req|
    if req.path.start_with?("/publishers/two_factor_authentications")
      req.remote_ip
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
      req.remote_ip
    end
  end

  # Throttle confirm 2fa disable emails for an IP address
  throttle("confirm_two_factor_authentication_removal/publisher_id", limit: 2, period: 24.hours) do |req|
    if req.path == "/publishers/confirm_two_factor_authentication_removal" && req.get?
      req.remote_ip
    end
  end

  # Throttle cancel 2fa disable emails for an IP address
  throttle("cancel_two_factor_authentication_removal/publisher_id", limit: 2, period: 24.hours) do |req|
    if req.path == "/publishers/cancel_two_factor_authentication_removal" && req.get?
      req.remote_ip
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
      req.remote_ip
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
