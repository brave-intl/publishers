# Record the publishers's successful login
Warden::Manager.after_authentication except: :fetch do |publisher, auth, opts|
  params = {
      publisher: publisher,
      user_agent: auth.request.headers["User-Agent"],
      accept_language: auth.request.headers["Accept-Language"]
  }

  LoginActivity.create!(params)
end