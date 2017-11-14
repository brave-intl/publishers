class ApplicationMailer < ActionMailer::Base
  INTERNAL_EMAIL = Rails.application.secrets[:internal_email].freeze

  default from: Rails.application.secrets[:from_email]
  layout "mailer"

  before_action :require_premailer

  def self.should_send_internal_emails?
    INTERNAL_EMAIL.present?
  end

  private

  def require_premailer
    require "premailer/rails"
  end
end
