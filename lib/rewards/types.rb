module Rewards
  module Types
    class PayoutStatus < T::Struct
      const :unverified, String
      const :uphold, String
      const :gemini, String
      const :bitflyer, String
    end

    class AllowList < T::Struct
      const :allow, T::Array[T.nilable(String)]
      const :block, T::Array[T.nilable(String)]
    end

    class CustodianRegions < T::Struct
      const :uphold, AllowList
      const :gemini, AllowList
      const :bitflyer, AllowList
    end

    class AutoContribute < T::Struct
      const :choices, T::Array[T.nilable(Integer)]
      const :defaultChoice, Integer
    end

    class Tips < T::Struct
      const :defaultTipChoices, Array
      const :defaultMonthlyChoices, Array
    end

    class ParametersResponse < T::Struct
      const :payoutStatus, PayoutStatus
      const :custodianRegions, CustodianRegions
      const :batRate, Float
      const :autocontribute, AutoContribute
      const :tips, Tips
    end
  end
end
