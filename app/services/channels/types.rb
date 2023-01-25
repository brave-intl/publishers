module Channels
  module Types
    # See: https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema
    OmniAuthHash = Struct.new(:provider, :uid, :info, :credentials, :extra, keyword_init: true)
  end
end
