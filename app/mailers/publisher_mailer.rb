class PublisherMailer < ApplicationMailer
  include PublishersHelper
  add_template_helper(PublishersHelper)

  # Contains instructions on how to verify domain.
  # Should be safe to forward to webmaster / IT peeps.
  def verification(publisher)
    @publisher = publisher
    generator = PublisherVerificationFileGenerator.new(publisher: @publisher)
    attachments[generator.filename] = generator.generate_file_content
    mail(
      to: @publisher.email,
      subject: default_i18n_subject(brave_publisher_id: @publisher.brave_publisher_id)
    )
  end

  # Contains registration details and a private reauthentication link
  def welcome(publisher)
    @publisher = publisher
    @private_reauth_url = publisher_private_reauth_url(@publisher)
    mail(
      to: @publisher.email,
      subject: default_i18n_subject(brave_publisher_id: @publisher.brave_publisher_id)
    )
  end
end
