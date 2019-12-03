require "test_helper"
require "generators/property/property_generator"

describe PropertyGenerator do
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  # it "generator runs without errors" do
  #   # No error raised? It passes.
  #   run_generator ["arguments"]
  # end
end
