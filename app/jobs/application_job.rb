# typed: true

class ApplicationJob < ActiveJob::Base
  # Send handled exceptions to Sentry and New Relic (which normally only sends unhandled exceptions).
  require "error_handler_delegator"
  def self.new(...)
    ErrorHandlerDelegator.new(super(...))
  end

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    LogException.perform(exception)
  end

  def self.instance
    @__instance__ ||= new
  end
end
