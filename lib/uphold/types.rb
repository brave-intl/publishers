module Uphold
  module Types
    UpholdUserCapability = Struct.new(
      :category,
      :enabled,
      :key,
      :name,
      :requirements,
      :restrictions
    )

    UpholdUser = Struct.new(
      :status,
      :memberAt,
      :id,
      :country,
      :currencies,
      :username
    )

    UpholdCard = Struct.new(
      :currency,
      :id,
      :label
    )

    UpholdCardAddress = Struct.new(
      :type
    )

    class UpholdCardAddresses; end

    class UpholdCards; end
  end
end
