# typed: true

class BuilderBaseService
  extend T::Helpers
  extend T::Sig

  class ::BSuccess < T::Struct
    prop :result, T.untyped # rubocop:disable Sorbet/ForbidUntypedStructProps
  end

  class ::BFailure < T::Struct
    prop :errors, T::Array[String]
  end

  ServiceResult = T.type_alias { T.any(BSuccess, BFailure) }

  abstract!

  sig { abstract.returns(T.self_type) }
  def self.build
  end

  sig { abstract.returns(ServiceResult) }
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
