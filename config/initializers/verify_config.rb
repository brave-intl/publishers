# Check sanity of config vars.

Class.new do
  VARS = %i(
    uphold_authorization_endpoint
  ).freeze

  def perform
    VARS.each do |var|
      value = Rails.application.secrets[var]
      raise("#{var.upcase} is required.") if value.blank?
      send(var, value)
    end
  rescue => exception
    require "sentry-raven"
    Raven.capture_exception(exception)
    puts(exception)
    exit(1)
  end

  private

  def uphold_authorization_endpoint(value)
    if !value.is_a?(String) || !value.include?('<UPHOLD_CLIENT_ID>') || !value.include?('<UPHOLD_SCOPE>') || !value.include?('<STATE>')
      raise 'UPHOLD_AUTHORIZATION_ENDPOINT must include "<UPHOLD_CLIENT_ID>", "<UPHOLD_SCOPE>" and "<STATE>".'
    end
  end
end.new.perform
