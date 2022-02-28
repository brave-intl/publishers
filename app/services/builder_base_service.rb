# typed: true

class BuilderBaseService
  extend T::Helpers
  extend T::Sig
  abstract!

  sig { abstract.returns(T.self_type) }
  def self.build
  end

  sig { abstract.params(args: T.nilable(T.untyped)).returns(T::Struct) }
  def call(args)
  end

  def pass(val = true)
    T.must(val)
    BSuccess.new(result: val)
  end

  def problem(e)
    BFailure.new(errors: [e])
  end
end
