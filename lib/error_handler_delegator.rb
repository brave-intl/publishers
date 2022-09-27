# typed: true

# # Send handled exceptions to New Relic (which normally only sends unhandled exceptions).
# See https://stackoverflow.com/questions/16567243/rescue-all-errors-of-a-specific-type-inside-a-module
class ErrorHandlerDelegator
  require "error_handler"
  include ErrorHandler

  def initialize(target)
    @target = target
  end

  def method_missing(...) # standard:disable all
    handle_known_exceptions do
      @target.send(...)
    end
  end
end
