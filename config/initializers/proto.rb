begin
  # Have to throw in a begin rescue block otherwise
  # Zeitwerk::NameError (expected file $DIR/protos/channel_responses.rb to define constant ChannelResponses, but didn't)
  # gets thrown.
  require "./protos/publisher_prefix_list"
rescue
end
begin
  require "./protos/channel_responses"
rescue
end
