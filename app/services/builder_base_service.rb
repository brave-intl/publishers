# typed: true

class BuilderBaseService
  extend T::Helpers
  extend T::Sig

  class SuccessStruct < T::Struct
    prop :success, TrueClass
    prop :result, T.any(Hash, String, Array, NilClass)
  end

  class FailureStruct < T::Struct
    prop :success, FalseClass
    prop :errors, T::Array[String]
  end

  class ResultStruct < T::Struct
    prop :success, T::Boolean
    prop :result, T.any(Hash, String, Array, NilClass)
  end
    
  abstract!

  sig {abstract.returns(BuilderBaseService)}
  def self.build; end

  sig {abstract.returns(T.any(SuccessStruct, FailureStruct, ResultStruct))}
  def call; end
end
