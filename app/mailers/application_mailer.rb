class ApplicationMailer < ActionMailer::Base
  INTERNAL_EMAIL = Rails.application.secrets[:internal_email].freeze

  default from: Rails.application.secrets[:support_email]
  layout "mailer"

  before_action :require_premailer
  before_action :add_logo

  def self.should_send_internal_emails?
    INTERNAL_EMAIL.present?
  end

  private

  def add_logo
    path = Rails.root.join("app/assets/images/brave_logo_horz_h30.png")
    attachments.inline["brave_logo_horz_h30.png"] = File.read(path)
  end

  def require_premailer
    require "premailer/rails"
  end
end
