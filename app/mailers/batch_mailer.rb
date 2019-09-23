# Used for designating batch jobs, usually to all publishers - thus we should queue as low
class BatchMailer < ApplicationMailer
  def notification_for_kyc(publisher)
    @publisher = publisher
    path = Rails.root.join("app/assets/images/mailer/batch/referral.png")
    image_file_name = File.basename(path)
    attachments.inline[image_file_name] = File.read(path)

    mail(to: @publisher.email || @publisher.pending_email, subject: default_i18n_subject)
  end
end
