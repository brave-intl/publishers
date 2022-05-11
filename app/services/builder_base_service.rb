# typed: true

class BuilderBaseService
  extend T::Helpers
  extend T::Sig
  abstract!

  sig { abstract.returns(T.self_type) }
  def self.build
  end

  sig { abstract.params(args: T.untyped).returns(T::Struct) }
  def call(args)
  end

  sig { params(val: T.untyped).returns(BSuccess) }
  def pass(val = true)
    T.must(val)
    BSuccess.new(result: val)
  end

  sig { params(e: T.any(String, T::Array[T.untyped])).returns(BFailure) }
  def problem(e)
    case e
    when String
      BFailure.new(errors: [e])
    when Array
      BFailure.new(errors: e)
    else
      T.absurd(e)
    end
  end

  sig { params(result: T.any(String, T::Array[T.untyped])).returns(BIndeterminate) }
  def shrug(result)
    case result
    when String
      BIndeterminate.new(result: [result])
    when Array
      BIndeterminate.new(result: result)
    else
      T.absurd(result)
    end
  end
end
