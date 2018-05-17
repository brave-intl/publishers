class InternalMailer < ApplicationMailer
  add_template_helper(PublishersHelper)
  layout 'internal_mailer'

  # Someone attempted to verify restricted channel and completed the automated steps.
  # An admin needs to manually confirm to finish the process.
  def channel_verification_approval_required(channel:)
    unless channel.details.is_a?(SiteChannelDetails)
      raise "Can only call this for SiteChannelDetails"
    end
    @channel = channel
    mail(
      to: INTERNAL_EMAIL,
      subject: "<Internal> #{@channel.details.publication_title} Verification approval required"
    )
  end
end
