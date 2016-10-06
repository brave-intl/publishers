class PublisherMailer < ApplicationMailer
  include PublishersHelper

  # Contains instructions on how to verify domain.
  # Should be safe to forward to webmaster / IT peeps.
  def verification_instructions
  end

  # Contains registration details and a private reauthentication link
  def welcome(publisher)
    @publisher = publisher
    @private_reauth_url = publisher_private_reauth_url(@publisher)
    mail(
      to: @publisher.email,
      subject: "Brave publisher registration: #{@publisher.publisher_id}"
    )
  end
end
