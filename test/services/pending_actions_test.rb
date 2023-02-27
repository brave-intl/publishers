# typed: false

require "test_helper"

class PendingActionsTest < ActiveJob::TestCase
  include PendingActions

  class TestContext
    attr_reader :session
    def initialize
      @session = {}
    end
  end

  class APendingAction < PendingAction
    call {}
  end

  test "saved pending action is accessible in context" do
    ctx = TestContext.new

    APendingAction.new.save! ctx

    assert_instance_of(APendingAction, PendingAction.saved(ctx))
  end

  class InstanceVariablesTestContext < TestContext
    attr_accessor :a_test
    attr_accessor :b_test
    def initialize
      super
      @a_test = nil
      @b_test = nil
    end
  end

  class APendingActionSetter < PendingAction
    call do
      @a_test = 1337
    end
  end

  class BPendingActionSetter < PendingAction
    call do
      @b_test = 1337
    end
  end

  test "execute in place will execute the correct action" do
    ctx = InstanceVariablesTestContext.new

    assert_nil ctx.a_test
    assert_nil ctx.b_test

    a_pending_action = APendingActionSetter.new
    b_pending_action = BPendingActionSetter.new

    assert_nil ctx.a_test
    assert_nil ctx.b_test

    a_pending_action.execute! ctx

    assert_equal 1337, ctx.a_test
    assert_nil ctx.b_test

    b_pending_action.execute! ctx
    assert_equal 1337, ctx.a_test
    assert_equal 1337, ctx.b_test
  end

  test "A class which is not inheriting a PendingAction cannot execute" do
    ctx = TestContext.new

    ctx.session[:pending_action] = {
      class: Object.to_s,
      args: []
    }

    assert_raise SecurityError do
      PendingAction.saved ctx
    end
  end

  class TestStepUpContext < InstanceVariablesTestContext
    attr_accessor :two_factor_auth

    def initialize
      super
      @two_factor_auth = false
    end

    def redirect_to(*args)
      raise NotImplementedError.new("Redirect not implemented")
    end

    def two_factor_enabled?(*args)
      @two_factor_auth
    end

    def two_factor_authentications_path
      ""
    end
  end

  class AStepUpSetter < StepUpAction
    call do |publisher_id|
      @a_test = 1337
    end
  end

  test "a StepUp action is executed in place if multi factor is disabled" do
    ctx = TestStepUpContext.new

    assert_nil ctx.a_test
    assert !ctx.two_factor_auth

    AStepUpSetter.new(publishers(:verified).id).step_up! ctx

    assert_equal 1337, ctx.a_test
  end
  test "a StepUp action is redirected if two factor authentication is enabled" do
    ctx = TestStepUpContext.new
    ctx.two_factor_auth = true

    assert_nil ctx.a_test
    assert ctx.two_factor_auth

    step_up_action = AStepUpSetter.new(publishers(:verified).id)
    assert_raise NotImplementedError do
      step_up_action.step_up! ctx
    end

    assert_nil ctx.a_test
  end

  class TestWronglyLoggedStepUpAction < TestStepUpContext
    def initialize(p)
      @publisher = p
    end

    def current_publisher
      @publisher
    end
  end

  test "a StepUp action raises a SecurityError if a publisher is logged in and he is trying to execute another publisher action" do
    ctx = TestWronglyLoggedStepUpAction.new(publishers(:default))

    assert_nil ctx.a_test
    assert !ctx.two_factor_auth
    assert ctx.current_publisher

    assert_raise SecurityError do
      AStepUpSetter.new(publishers(:verified).id).execute! ctx
    end

    assert_nil ctx.a_test
  end
end
