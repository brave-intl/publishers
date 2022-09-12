module Rewards
  module Types
    class ParametersResponse < T::Struct
      const :payoutStatus, T::Hash[T.any(String, Symbol), String]
      const :custodianRegions, T::Hash[T.any(String, Symbol), T::Hash[T.any(String, Symbol), T::Array[T.nilable(String)]]]
      const :batRate, Float
      const :autocontribute, T::Hash[T.any(String, Symbol), T.any(Integer, T::Array[T.nilable(Integer)])]
      const :tips, T::Hash[T.any(String, Symbol), T::Array[T.nilable(T.any(Float, Integer))]]
    end
  end
end
