module Uphold
  module Types
    class UpholdCard < T::Struct
      const :currency, String
      const :id, String
      const :label, String
    end

    UpholdCards = T.type_alias { T::Array[UpholdCard] }
  end
end
