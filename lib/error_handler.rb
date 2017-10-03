# A module with global error handling logic (to send to Sentry)
# In your class:
#   include ErrorHandler
# Then proceed to rescue things normally.
module ErrorHandler
  extend ActiveSupport::Concern

  included do
    include ActiveSupport::Rescuable
    rescue_from StandardError, with: :handle_standard_error
  end

  def handle_known_exceptions
    yield
  rescue => exception
    rescue_with_handler(exception)
    # reraise to run normal exception handling
    raise
  end

  def handle_standard_error(exception)
    if %w(production staging).include?(Rails.env)
      require "sentry-raven"
      Raven.capture_exception(exception)
    else
      Rails.logger.warn(exception)
    end
  end
end
