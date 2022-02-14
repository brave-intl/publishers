# typed: true

class BuilderBaseService
  extend T::Helpers
  extend T::Sig
  abstract!

  class ::BSuccess < T::Struct
    prop :result, T.any(T::Hash[T.untyped, T.untyped], T::Array[T.untyped], Integer, Float, T::Boolean)
  end

  class ::BFailure < T::Struct
    prop :errors, T::Array[String]
  end

  ::BServiceResult = T.type_alias { T.any(BSuccess, BFailure) }

  sig { abstract.returns(T.self_type) }
  def self.build
  end

  sig { abstract.returns(BServiceResult) }
  def call
  end

  def pass(val = true)
    T.must(val)
    BSuccess.new(result: val)
  end

  def problem(e)
    BFailure.new(errors: [e])
  end
end
