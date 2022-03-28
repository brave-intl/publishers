class BSuccess < T::Struct
  prop :result, T.any(T::Hash[T.untyped, T.untyped], T::Array[T.untyped], Integer, Float, T::Boolean)
end

class BFailure < T::Struct
  prop :errors, T::Array[String]
end

BServiceResult = T.type_alias { T.any(BSuccess, BFailure, T::Struct) }
