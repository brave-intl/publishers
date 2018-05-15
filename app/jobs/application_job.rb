class ApplicationJob < ActiveJob::Base
  # Send handled exceptions to Sentry (which normally only sends unhandled exceptions).
  require "error_handler_delegator"

  def self.new(*args, &block)
    ErrorHandlerDelegator.new(super)
  end

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    require "sentry-raven"
    Raven.capture_exception(exception)
  end

  def self.instance
    @__instance__ ||= new
  end
end
