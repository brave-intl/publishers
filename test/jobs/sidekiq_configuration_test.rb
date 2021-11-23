# typed: false
# rubocop:disable all
require "test_helper"

class SidekiqConfigurationTest < ActiveJob::TestCase
  test "sidekiq.yml contains only valid classes" do
    file_path = Rails.root.join("config/sidekiq.yml")

    configuration = YAML.load_file(file_path)

    assert configuration.present?

    jobs = configuration.dig(:schedule).keys
    jobs.each do |job|
      # Rails can convert a string to a class with constantize
      # https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-constantize
      # This raises a NameError if the configuration isn't valid
      job.constantize
    end
  end
end
# rubocop:enable all