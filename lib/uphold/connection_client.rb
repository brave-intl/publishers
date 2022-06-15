# typed: true

module Uphold
  class ConnectionClient
    extend T::Sig

    sig { params(conn: UpholdConnection).void }
    def initialize(conn)
      @conn = conn
    end

    sig { returns(Uphold::Cards) }
    def cards
      @_cards ||= Uphold::Cards.new(@conn.access_token)
    end

    sig { returns(Uphold::Users) }
    def users
      @_users ||= Uphold::Users.new(@conn.access_token)
    end
  end
end
