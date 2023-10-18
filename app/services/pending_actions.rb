# PendingActions service allows to create stored actions which may be
# executed in a secondary moment after them being saved.
#
# This module is thought to be included in rails controllers and provide
# the following:
# - An helper method that returns a pending action saved in a session `saved_pending_action`
# - A PendingAction class which should be inherited by any pending action and provide a container
#   for executable code snippets. The execute! method will execute the action in place.
# - A StepUp class which extends a PendingAction to provide a step_up! action. Step up executes
#   only if a succesful step_up happened.
module PendingActions
  # Include here all the included helpers/modules required in sub-actions
  # This is required to have a similar available API in all the possible execution contexts
  # requiring a PendingAction
  include PublishersHelper
  include Logout
  include TwoFactorRegistration

  # An helper method that returns a pending action saved in a session
  # @return [PendingAction]
  def saved_pending_action
    PendingAction.saved self
  end

  # PendingAction should be inherited by any pending action and provide a container
  # for executable code snippets. The execute! method will execute the action in place.
  class PendingAction
    # Meta-Programming magic method. It defines a call method in each sub-class, which gets
    # a block as an argument and saves in the sub-class @@callable class variable.
    # It also defines an `callable` helper on the class itself.
    #
    # This hack is required to save a Proc in a class variable.
    # Normal methods cannot be employed for this purpose since, even if an UnboundedMethod
    # is similar to a Proc in his functioning, ruby impose limits on which reiceiver
    # it is binded to. Only subclasses of a given class can be binded to a UnboundedMethod
    # of a given super-class.
    #
    # XXX: If the call signature changes, it is advised to change the pending action class name.
    def self.inherited(base)
      base.define_singleton_method(:call) do |&block|
        base.class_variable_set(:@@callable, block)
      end
      base.define_singleton_method(:callable) { base.class_variable_get(:@@callable) }
    end

    # Creates a PendingAction object.
    #
    # @param [[Object]] *args , a list of session serializable arguments
    def initialize(*args)
      @class = self.class
      @args = args
    end

    # Given a context it will execute a saved callable in that particular context.
    # Context should responde to the session method, and return a session object,
    # in that particular case.
    #
    # @param [Object] context, execute the callable in that specific context
    # @return [Object] the class callable
    def execute! context
      context.session.delete(:pending_action)
      context.instance_exec(*@args, &self.class.callable)
    end

    # Given a context it will retrieve the current PendingAction saved in session.
    #
    # @param [Object] context, retrieves the current PendingAction in that specific context
    # @return [PendingAction] the class callable
    def self.saved context
      pending_action = context.session[:pending_action]
      pending_action_class = pending_action[:class].constantize # rubocop:disable Sorbet/ConstantsFromStrings
      unless pending_action_class < PendingAction
        context.session.delete(:pending_action)
        raise SecurityError.new("#{pending_action_class} is not a subclass of PendingAction")
      end
      pending_action_class.send(:new, *pending_action[:args])
    end

    # Saves the current PendingAction (self) in the context's session.
    #
    # @param [Object] context, saves the current PendingAction in that specific context
    def save! context
      context.session[:pending_action] = {
        class: @class.to_s,
        args: @args
      }
    end
  end

  # StepUpAction inherits from PendingAction and extends with the `step_up!` method.
  # `step_up!` will either execute in place, if multi-factor is not enabled for that particular user.
  # or will save the action and redirect to the two factor authentication controller.
  # It is the edge multi-factor controller (Either U2F or TOTP) to execute the saved pending action,
  # when available.
  #
  # Since it's not always true that there is a logged-in current_publisher, any StepUp action
  # requires the first argument to be a `publisher_id` so that even the receiving/executor will
  # know on which publisher execute such action.
  #
  # All the authentication on the publisher_id is mandated before the StepUpAction creation.
  class StepUpAction < PendingAction
    # @return [Publisher] the current publisher object, saved in the action arguments as first argument
    def current_publisher
      Publisher.find(@args.first)
    end
    # alias current_publisher to publisher shortcut
    alias_method :publisher, :current_publisher

    # Extends the execute! method to execute only if current context user is the same of the saved current user
    def execute! context
      if defined?(context.current_publisher) && context.current_publisher && context.current_publisher != current_publisher
        raise SecurityError.new(
          "Trying to execute #{self.class} on Publisher #{current_publisher.id} instead of #{context.current_publisher.id}"
        )
      end
      super context
    end

    # Either executes in place the action or, saves the action and redirects to the two_factor_authentication controller
    # based on if the two factor authentication is enabled or not.
    def step_up! context
      if context.two_factor_enabled?(current_publisher)
        save! context
        if context.class.name.include?("Nextv1")
          execute! context
          # context.render(json: {
          #   error: '2fa_required'
          # }, status: 200)
        else
          context.redirect_to context.two_factor_authentications_path
        end
      else
        execute! context
      end
    end
  end
end
