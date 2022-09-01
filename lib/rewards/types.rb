module Rewards
  module Types
    class ParametersResponse < T::Struct
      const :payoutStatus, PayoutStatus
      const :custodianRegions, CustodianRegions
      const :batRate, Float
      const :autocontribute, AutoContribute
      const :tips, Tips
      const :defaultMonthlyChoices, T::Array[T.nilable(Float)]
    end

    class PayoutStatus < T::Struct
      const :unverified, String
      const :uphold, String
      const :gemini, String
      const :bitflyer, String
    end

    class CustodianRegions < T::Struct
      const :uphold, AllowList
      const :gemini, AllowList
      const :bitflyer, AllowList
    end

    class AllowList < T::Struct
      const :allow, T::Array[T.nilable(String)]
      const :block, T::Array[T.nilable(String)]
    end

    class AutoContribute < T::Struct
      const :choices, T::Array[T.nilable(Integer)]
      const :defaultChoice, Integer
    end

    class Tips < T::Struct
      const :defaultTipChoices, T::Array[T.nilable(Float)]
    end
  end
end
