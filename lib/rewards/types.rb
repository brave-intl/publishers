module Rewards
  module Types
    ParametersResponse = Struct.new(
      :payoutStatus,
      :custodianRegions,
      :batRate,
      :autocontribute,
      :tips,
      keyword_init: true
    )
  end
end
