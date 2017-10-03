class ApplicationJob < ActiveJob::Base
  # Send handled exceptions to Sentry (which normally only sends unhandled exceptions).
  require "error_handler_delegator"

  def self.new(*args, &block)
    ErrorHandlerDelegator.new(super)
  end

  def self.instance
    @__instance__ ||= new
  end
end
