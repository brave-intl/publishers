module Uphold
  module Types
    class UpholdUser < T::Struct
      const :status, String
      const :memberAt, T.nilable(String)
      const :id, String
      const :country, T.nilable(String)
    end

    class UpholdCard < T::Struct
      const :currency, String
      const :id, String
      const :label, String
    end

    UpholdCards = T.type_alias { T::Array[UpholdCard] }
  end
end
