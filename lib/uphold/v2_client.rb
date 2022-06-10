# typed: true

module Uphold
  class V2Client
    extend T::Sig

    sig { params(conn: UpholdConnection).void }
    def initialize(conn:)
      @conn = conn
    end

    sig { returns(Uphold::Cards) }
    def cards
      @_cards ||= Uphold::Cards.new(@conn.access_token)
    end
  end
end
