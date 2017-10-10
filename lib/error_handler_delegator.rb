# # Send handled exceptions to Sentry (which normally only sends unhandled exceptions).
# See https://stackoverflow.com/questions/16567243/rescue-all-errors-of-a-specific-type-inside-a-module
class ErrorHandlerDelegator
  require "error_handler"
  include ErrorHandler

  def initialize(target)
    @target = target
  end

  def method_missing(*args, &block)
    handle_known_exceptions do
      @target.send(*args, &block)
    end
  end
end
