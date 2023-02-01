# typed: false
# frozen_string_literal: true

require "test_helper"

class BuilderBaseServiceTest < ActiveSupport::TestCase
  DEFAULT_VALUE = "default_value"

  class ValidChildOfBuilderBaseService < BuilderBaseService
    def self.build
      new
    end

    def call(service: "service")
      pass
    end
  end

  test ValidChildOfBuilderBaseService.name do
    output = ValidChildOfBuilderBaseService.build.call
    assert_instance_of(BSuccess, output)
    assert output.result == true
  end

  class FailedChildOfBuilderBaseService < BuilderBaseService
    def self.build
      new
    end

    def call(service: "service")
      BFailure.new(errors: ["We could not succeed"])
    end
  end

  test FailedChildOfBuilderBaseService.name do
    output = FailedChildOfBuilderBaseService.build.call
    assert_instance_of(BFailure, output)
    assert !output.errors.empty?
  end
end
