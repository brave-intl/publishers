module Uphold
  module Types
    class UpholdUserCapability < T::Struct
      const :category, String
      const :enabled, T::Boolean
      const :key, String
      const :name, String
      const :requirements, T::Array[T.nilable(String)]
      const :restrictions, T::Array[T.nilable(String)]
    end

    class UpholdUser < T::Struct
      const :status, String
      const :memberAt, T.nilable(String)
      const :id, String
      const :country, T.nilable(String)
      prop :currencies, T.nilable(T::Array[String]), default: []
      const :username, T.nilable(String) # Doesn't exist so far as I know, but maintaining for backwards compatibility
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
