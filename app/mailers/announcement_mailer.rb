# frozen_string_literal: true

class AnnouncementMailer < ApplicationMailer
  # include PublishersHelper
  # add_template_helper(PublishersHelper)

  def multi_chan(email)
    mail(
      to: email,
      subject: default_i18n_subject
    )
  end
end
