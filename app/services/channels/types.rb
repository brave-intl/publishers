module Channels
  module Types
    extend T::Sig

    # See: https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema
    class OmniAuthHash < T::Struct
      # TODO: Will need to validate these actual types,
      # it could be that hash type values vary by omniauth provider
      const :provider, String
      const :uid, String
      const :info, T::Hash[String, String]
      const :credentials, T::Hash[String, T.untyped]
      const :extra, T.nilable(T::Hash[String, T.untyped])
    end
  end
end
