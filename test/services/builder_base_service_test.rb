# typed: false
# frozen_string_literal: true

require "test_helper"

class BuilderBaseServiceTest < ActiveSupport::TestCase
  test "BuilderBaseService.call" do
    assert_raises NotImplementedError do
      BuilderBaseService.call
    end
  end

  class ValidChildOfBuilderBaseService < BuilderBaseService
    def call
      true
    end
  end

  test ValidChildOfBuilderBaseService.name do
    output = ValidChildOfBuilderBaseService.call
    assert_instance_of(OpenStruct, output)
    assert output.result
    assert output.success?
    assert output.errors.empty?
  end

  class InvalidChildOfBuilderBaseService < BuilderBaseService
  end

  test InvalidChildOfBuilderBaseService.name do
    assert_raises NotImplementedError do
      InvalidChildOfBuilderBaseService.call
    end
  end

  class FailingChildOfBuilderBaseService < BuilderBaseService
    def call
      raise StandardError
    end
  end

  test FailingChildOfBuilderBaseService.name do
    output = FailingChildOfBuilderBaseService.call
    assert !output.success?
    assert !output.errors.empty?
    assert_nil output.result
  end
end
