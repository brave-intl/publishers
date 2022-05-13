# I've updated the typing here because it turns out that it's not actually very helpful.
# The only cases where I'm using BSuccess or BFailure instead of an explicit response
# object are when I'm solely interested in whether another service has succeeded or failed.
#
# If I need an explicit type, I am going to define it as a response from the service in question
# and pattern match against that type, not dig around in a generic response object.
class BSuccess < T::Struct
  prop :result, T.any(T::Hash[T.untyped, T.untyped], T::Array[T.untyped], Integer, Float, T::Boolean)
end

class BFailure < T::Struct
  prop :errors, T::Array[T.untyped]
end

# There are definitely cases where "Success" and "Failure" are not exactly correct and we should be explicit about it.
class BIndeterminate < T::Struct
  prop :result, T::Array[T.untyped]
end

BServiceResult = T.type_alias { T.any(BSuccess, BFailure, T::Struct, BIndeterminate) }
