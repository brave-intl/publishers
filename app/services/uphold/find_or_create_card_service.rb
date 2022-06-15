# typed: true

# Going to strict typing is a whole different ballgame.

class Uphold::FindOrCreateCardService < BuilderBaseService
  include Uphold::Types
  include Oauth2::Responses
  include Oauth2::Errors
  extend T::Helpers
  extend T::Sig

  # This doesn't work. I keep running into all sorts of issues with inheritance and sorbet
  #  sig { override.returns(T.self_type) }
  def self.build
    new
  end

  sig { override.params(conn: UpholdConnection).returns(BServiceResult) }
  def call(conn)
    result = conn.refresh_authorization!

    case result
    when UpholdConnection
      @conn = result

      if card_exists?
        @card
      elsif has_no_cards?
        create_card
      else
        find_or_create_card
      end
    when BFailure
      result
    when ErrorResponse
      BFailure.new(errors: [result])
    else
      T.absurd(result)
    end
  end

  private

  sig { returns(T::Boolean) }
  def card_exists?
    return false if @conn.address.nil?
    result = client.cards.get(@conn.address)

    case result
    when UpholdCard
      @card = result
      true
    when Faraday::Response
      raise_unless_not_found(result)
    else
      T.absurd(result)
    end
  end

  sig { returns(UpholdCard) }
  def create_card
    result = client.cards.create(
      label: UpholdConnection::UPHOLD_CARD_LABEL,
      currency: @conn.default_currency,
      settings: {starred: true}
    )

    case result
    when UpholdCard
      result
    when Faraday::Response
      raise ClientError.new(response: result)
    else
      T.absurd(result)
    end
  end

  sig { returns(T::Boolean) }
  def has_no_cards?
    result = client.cards.list

    case result
    when Faraday::Response
      raise_unless_not_found(result)
    when Array
      if result.empty?
        true
      else
        @cards = result
        false
      end
    end
  end

  sig { returns(UpholdCard) }
  def find_or_create_card
    # User's can change the label's on their cards so if we couldn't find it, we'll have to iterate until we find a card.
    # We want to make sure isn't the browser's wallet card and isn't a channel card. We can do this by checking the private address
    #
    # https://sorbet.org/docs/error-reference#7001
    card = T.let(nil, T.nilable(UpholdCard))

    @cards.each do |c|
      if c.label.eql?(UpholdConnection::UPHOLD_CARD_LABEL) && c.currency == @conn.default_currency
        card = c
        break

        # The implementation pulled from the create_uphold_card_job method assigned
        # cards when the currency was mismatched.  This is probably the reason
        # we have had bugs WRT to payouts.
      elsif c.currency != @conn.default_currency || has_private_address?(c.id)
        next
      else
        card = c
      end
    end

    if card.nil?
      create_card
    else
      card
    end
  end

  sig { returns(Uphold::ConnectionClient) }
  def client
    @_client ||= Uphold::ConnectionClient.new(@conn)
  end

  sig { params(card_id: String).returns(T::Boolean) }
  def has_private_address?(card_id)
    existing_private_cards ||= T.unsafe(UpholdConnectionForChannel).select(:card_id).where(uphold_connection: @conn, uphold_id: @conn.uphold_id).to_a
    return true if existing_private_cards.include?(card_id)

    result = client.cards.list_addresses(card_id)

    case result
    when Array
      result.detect { |a| a.type == UpholdConnectionForChannel::NETWORK }.present?
    else
      raise ClientError.new(response: result)
    end
  end

  sig { params(response: Faraday::Response).returns(FalseClass) }
  def raise_unless_not_found(response)
    if response.status == 404
      false
    else
      raise ClientError.new(response: response)
    end
  end
end
