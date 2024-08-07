module NextjsTestSetup
  def setup_nextjs_test
    Capybara.app_host = "https://#{ENV["NEXT_HOST"]}"
    ::Rails.application.config.action_mailer.default_url_options = {host: "https://#{ENV["NEXT_HOST"]}"}
    Publishers::Application.default_url_options = Publishers::Application.config.action_mailer.default_url_options
  end
end
