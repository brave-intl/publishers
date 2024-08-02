module NextJsHelpers
  def nextjs_pre
    if self.class.const_defined?(:USE_NEXTJS) && self.class::USE_NEXTJS
      @original_app_host = Capybara.app_host
      @original_default_url_options = Publishers::Application.default_url_options
      @original_default_mail_options = ::Rails.application.config.action_mailer.default_url_options

      raise "no NEXT_HOST env var" unless ENV["NEXT_HOST"].present?
      Capybara.app_host = "https://#{ENV['NEXT_HOST']}"
      ::Rails.application.config.action_mailer.default_url_options = { host: "https://#{ENV['NEXT_HOST']}" }
      Publishers::Application.default_url_options = Publishers::Application.config.action_mailer.default_url_options
    end
  end

  def nextjs_post
    # Restore Capybara config if it was changed
    if @original_app_host && @original_default_url_options
      Capybara.app_host = @original_app_host
      Publishers::Application.default_url_options = @original_default_url_options
      ::Rails.application.config.action_mailer.default_url_options = @original_default_mail_options
    end
  end
end