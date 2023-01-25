# typed: true

module Uphold
  class ConnectionClient
    def initialize(conn)
      @conn = conn
    end

    def cards
      @_cards ||= Uphold::Cards.new(@conn.access_token)
    end

    def users
      @_users ||= Uphold::Users.new(@conn.access_token)
    end
  end
end
