class InternalMailer < ApplicationMailer
  add_template_helper(PublishersHelper)
  add_template_helper(AdminHelper)
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

  def email_report(email:, subject:, body:, filename:)
    name = filename.split('/').last
    attachments[name] = File.read(filename)

    mail(to: email, subject: subject, body: body)
  end

  def tagged_in_note(tagged_user:, note:)
    return unless tagged_user.admin?

    @note = note

    mail(
      to: tagged_user.email,
      subject: "New reply or mention in note on publisher #{note.publisher.name || note.publisher.email}"
    )
  end
end
