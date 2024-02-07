# typed: false

# Send handled exceptions to New Relic (which normally only sends unhandled exceptions).
# See https://stackoverflow.com/questions/16567243/rescue-all-errors-of-a-specific-type-inside-a-module
module ErrorHandler
  extend ActiveSupport::Concern

  included do
    include ActiveSupport::Rescuable
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActionController::InvalidAuthenticityToken, with: :redirect_to_referer_or_home
    rescue_from SecurityError, with: :redirect_to_referer_or_home
  end

  def handle_known_exceptions
    yield
  rescue => exception
    rescue_with_handler(exception)
    # reraise to run normal exception handling
    raise
  end

  def handle_standard_error(exception)
    if %w[production staging].include?(Rails.env)
      publisher_params = {}
      if (publisher = introspect_publisher)
        publisher_params[:publisher_id] = publisher.id
        publisher_params[:email] = publisher.email
      end
      LogException.perform(exception, publisher: publisher_params)
    else
      Rails.logger.warn(exception)
    end

    # re-raise the exception now that it's been captured by New Relic or logged
    # so that the standard rails error flow can happen
    raise exception
  end

  def redirect_to_referer_or_home
    flash[:notice] = "Invalid attempt, please try again."
    redirect_to request&.referer || root_path
  end

  def introspect_publisher
    if defined?(@publisher) && @publisher
      return @publisher
    end
    if defined?(current_publisher) && current_publisher
      current_publisher
    end
  end
end
