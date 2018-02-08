class ApplicationMailer < ActionMailer::Base
  INTERNAL_EMAIL = Rails.application.secrets[:internal_email].freeze

  default from: Rails.application.secrets[:from_email]
  layout "mailer"

  before_action :require_premailer
  before_action :add_images

  def self.should_send_internal_emails?
    INTERNAL_EMAIL.present?
  end

  private

  def add_image(image_path)
    path = Rails.root.join("app/assets/images/#{image_path}")
    image_file_name = File.basename(image_path)
    attachments.inline[image_file_name] = File.read(path)
  end

  def add_images
    add_image("mailer/brave-payments.png")
    add_image("mailer/logo-medium.png")
    add_image("mailer/logo-reddit.png")
    add_image("mailer/logo-rocketchat.png")
    add_image("mailer/logo-twitter.png")
    add_image("mailer/footer-top-pattern.png")
    add_image("mailer/logo-bat.png")

    if self.class == PromoMailer
      add_image("tweet.png")
      add_image("f-share.png")
      add_image("mailer/header-pattern-promo.png")
    elsif self.class == PublisherMailer
      add_image("mailer/header-pattern.png")
    else
      raise
    end
  end

  def require_premailer
    require "premailer/rails"
  end
end
