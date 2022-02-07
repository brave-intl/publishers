# typed: false
# frozen_string_literal: true

require "test_helper"

class BuilderBaseServiceTest < ActiveSupport::TestCase
  DEFAULT_VALUE = "default_value"

  class InvalidChildOfBuilderBaseService < BuilderBaseService
  end

  class ValidChildOfBuilderBaseService < BuilderBaseService
    def call(kwarg: true)
      kwarg
    end
  end

  class UseRunBaseService < BuilderBaseService
    def self.build
      new(DEFAULT_VALUE)
    end

    def initialize(service)
      @service = service
    end

    def run
      @service
    end
  end

  class UseBuildBaseService < BuilderBaseService
    def self.build
      new(DEFAULT_VALUE)
    end

    def initialize(service)
      @service = service
    end

    def call
      @service
    end
  end

  class FailingChildOfBuilderBaseService < BuilderBaseService
    def call
      raise StandardError
    end
  end

  test "BuilderBaseService.call" do
    assert_raises NotImplementedError do
      BuilderBaseService.call
    end
  end

  test UseRunBaseService.name do
    output = UseRunBaseService.build.call
    assert_instance_of(OpenStruct, output)
    assert output.result == DEFAULT_VALUE
    assert output.success?
    assert output.errors.empty?
  end

  test UseBuildBaseService.name do
    output = UseBuildBaseService.call
    assert_instance_of(OpenStruct, output)
    assert output.result == DEFAULT_VALUE
    assert output.success?
    assert output.errors.empty?
    assert UseBuildBaseService.build.call == DEFAULT_VALUE
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

  test InvalidChildOfBuilderBaseService.name do
    assert_raises NotImplementedError do
      InvalidChildOfBuilderBaseService.call
    end
  end

  test FailingChildOfBuilderBaseService.name do
    output = FailingChildOfBuilderBaseService.call
    assert !output.success?
    assert !output.errors.empty?
    assert_nil output.result
  end
end
