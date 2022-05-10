# typed: false
# Record the publisher's successful login
Warden::Manager.after_authentication except: :fetch do |publisher, auth, _opts|
  params = {
    publisher: publisher,
    user_agent: auth.request.headers["User-Agent"],
    accept_language: auth.request.headers["Accept-Language"]
  }

  auth.cookies[:_publisher_id] = {value: publisher.id, same_site: :lax, secure: true, httponly: true, expires: 20.year.from_now}

  LoginActivity.create!(params)

  publisher.&selected_wallet_provider.sync_connection! if publisher && !Rails.env.test?
end
