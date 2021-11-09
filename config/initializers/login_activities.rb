# typed: ignore
# Record the publisher's successful login
Warden::Manager.after_authentication except: :fetch do |publisher, auth, _opts|
  params = {
    publisher: publisher,
    user_agent: auth.request.headers["User-Agent"],
    accept_language: auth.request.headers["Accept-Language"]
  }

  LoginActivity.create!(params)

  if publisher && !Rails.env.test?
    Util::Wallet::ConnectionSyncer.build.call(publisher: publisher)
  end
end
