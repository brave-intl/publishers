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
