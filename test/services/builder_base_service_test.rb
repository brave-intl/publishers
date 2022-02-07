# typed: false
# frozen_string_literal: true

require "test_helper"

class BuilderBaseServiceTest < ActiveSupport::TestCase
  test "BuilderBaseService.call" do
    assert_raises NotImplementedError do
      BuilderBaseService.call
    end
  end

  test "UseBuildBaseService" do
    class UseBuildBaseService < BuilderBaseService
      def self.build
        new("default_value")
      end

      def initialize(service)
        @service = service
      end

      def call
        @service
      end
    end

    output = UseBuildBaseService.call
    assert_instance_of(OpenStruct, output)
    assert output.result == "default_value"
    assert output.success?
    assert output.errors.empty?
  end

  class ValidChildOfBuilderBaseService < BuilderBaseService
    def call(kwarg: true)
      kwarg
    end
  end

  test ValidChildOfBuilderBaseService.name do
    output = ValidChildOfBuilderBaseService.call
    assert_instance_of(OpenStruct, output)
    assert output.result
    assert output.success?
    assert output.errors.empty?
  end

  test "#{ValidChildOfBuilderBaseService.name} kwargs" do
    output = ValidChildOfBuilderBaseService.call(kwarg: nil)
    assert_instance_of(OpenStruct, output)
    assert !output.result
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
