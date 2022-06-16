module Uphold
  module Types
    class UpholdUser < T::Struct
      const :status, String
      const :memberAt, T.nilable(String)
      const :id, String
      const :country, T.nilable(String)
      prop :currencies, T.nilable(T::Array[String]), default: []
    end

    class UpholdCard < T::Struct
      const :currency, String
      const :id, String
      const :label, String
    end

    class UpholdCardAddress < T::Struct
      const :type, String
    end

    UpholdCardAddresses = T.type_alias { T::Array[UpholdCardAddress] }
    UpholdCards = T.type_alias { T::Array[UpholdCard] }
  end
end
