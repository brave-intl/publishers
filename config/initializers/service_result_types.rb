# I've updated the typing here because it turns out that it's not actually very helpful.
# The only cases where I'm using BSuccess or BFailure instead of an explicit response
# object are when I'm solely interested in whether another service has succeeded or failed.
#
# If I need an explicit type, I am going to define it as a response from the service in question
# and pattern match against that type, not dig around in a generic response object.
BSuccess = Struct.new(:result, keyword_init: true)

BFailure = Struct.new(:errors, keyword_init: true)

# There are definitely cases where "Success" and "Failure" are not exactly correct and we should be explicit about it.
BIndeterminate = Struct.new(:result, keyword_init: true)

class BServiceResult; end
