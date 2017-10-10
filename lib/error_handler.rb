# Send handled exceptions to Sentry (which normally only sends unhandled exceptions).
# See https://stackoverflow.com/questions/16567243/rescue-all-errors-of-a-specific-type-inside-a-module
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
