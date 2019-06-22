# Used for designating batch jobs, usually to all publishers - thus we should queue as low
class BatchMailer < ApplicationMailer
  def update_to_tos(publisher)
    @publisher = publisher
    mail(
      to: @publisher.email || @publisher.pending_email,
      subject: default_i18n_subject
    )
  end
end
