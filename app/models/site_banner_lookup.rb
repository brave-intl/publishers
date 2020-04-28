class SiteBannerLookup < ActiveRecord::Base
  belongs_to :channel
  belongs_to :publisher
  def set_sha2_base16
    self.sha2_base16 = Digest::SHA2.hexdigest(channel_identifier)
  end

  def set_wallet_status(publisher:)
    begin
      # Have to throw in a begin rescue block otherwise
      # Zeitwerk::NameError (expected file $DIR/protos/channel_responses.rb to define constant ChannelResponses, but didn't)
      # gets thrown.
      require './protos/channel_responses'
    rescue
    end

    self.wallet_status = if publisher.paypal_connection.present? && publisher.paypal_connection.country == PaypalConnection::JAPAN_COUNTRY_CODE
        if publisher.paypal_connection.verified_account?
          PublishersPb::WalletConnectedState::PAYPAL_ACCOUNT_KYC
        else
          PublishersPb::WalletConnectedState::PAYPAL_ACCOUNT_NO_KYC
        end
    elsif publisher.uphold_connection&.is_member && publisher.uphold_connection.address.present?
      PublishersPb::WalletConnectedState::UPHOLD_ACCOUNT_KYC
    else
      PublishersPb::WalletConnectedState::UPHOLD_ACCOUNT_NO_KYC
    end
  end
end
