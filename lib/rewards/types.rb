module Rewards
  module Types
    ParametersResponse = Struct.new(
      :payoutStatus,
      :custodianRegions,
      :batRate,
      :autocontribute,
      :tips
    )
  end
end
