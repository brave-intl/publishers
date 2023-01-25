module Uphold
  module Types
    UpholdUserCapability = Struct.new(
       :category,
       :enabled,
       :key,
       :name,
       :requirements,
       :restrictions,
       keyword_init: true

    )

    UpholdUser = Struct.new(
       :status,
       :memberAt,
       :id,
       :country,
       :currencies,
       :username,
       keyword_init: true

    )

    UpholdCard = Struct.new(
       :currency,
       :id,
       :label,
       keyword_init: true

    )

    UpholdCardAddress = Struct.new(
       :type,
       keyword_init: true

    )

    class UpholdCardAddresses; end 

      class UpholdCards; end
  end
end
