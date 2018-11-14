# "Magic sign in link" / One time sign-in token via email
module MailerServices
  class PartnerLoginLinkEmailer < BaseService
    attr_accessor :error
    attr_reader :partner

    def initialize(partner:)
      @partner = partner
    end

    # Returns true if everything worked;
    # Returns false and sets #error if something didn't work.
    def perform
      send_email
    end

    def send_email
      return false if !partner
      # Updates the authentication_token and saves the Partner
      token = PartnerTokenGenerator.new(partner: partner).perform
      PublisherMailer.login_email(partner).deliver_later
    end
  end
end
