class BaseService
  require "error_handler_delegator"

  def self.new(*args, &block)
    ErrorHandlerDelegator.new(super)
  end

  def self.instance
    @__instance__ ||= new
  end
end
