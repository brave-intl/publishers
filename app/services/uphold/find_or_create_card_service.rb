# typed: true

class Uphold::FindOrCreateCardService < BuilderBaseService
  include Uphold::Types
  include Oauth2::Responses
  include Oauth2::Errors
  extend T::Helpers
  extend T::Sig

  def self.build
    new
  end

  sig { override.params(conn: UpholdConnection).returns(BServiceResult) }
  def call(conn)
    result = conn.refresh_authorization!

    case result
    when UpholdConnection
      @client = conn.uphold_client
      @conn = result

      if card_exists? || has_no_cards?
        @card 
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

  def card_exists?
    return false if !@conn.address.present?
    result = @client.cards.get(@conn.address)

    case result
    when UpholdCard
      @card = result
      true
    when ClientError
      raise result
    else
      T.absurd(result)
    end
  end

  def create_card
    @card = @client.cards.create(
      label: UpholdConnection::UPHOLD_CARD_LABEL, 
      currency: @conn.default_currency,
      settings: { starred: true }
    )
  end

  def has_no_cards?
    @cards = @client.cards.list

    if @cards.empty?
      create_card
      return true
    end
  end

  def find_or_create_card
    # User's can change the label's on their cards so if we couldn't find it, we'll have to iterate until we find a card.
    # We want to make sure isn't the browser's wallet card and isn't a channel card. We can do this by checking the private address
    card = nil

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

  def has_private_address?(card_id)
    existing_private_cards ||= UpholdConnectionForChannel.select(:card_id).where(uphold_connection: @conn, uphold_id: @conn.uphold_id).to_a
    return true if existing_private_cards.include?(card_id)

    addresses = UpholdClient.address.all(uphold_connection: @conn, id: card_id)
    addresses.detect { |a| a.type == UpholdConnectionForChannel::NETWORK }.present?
  end
end
