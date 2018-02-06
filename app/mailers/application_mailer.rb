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

  def add_image(image_file_name, source = "mailer")
    if source == "mailer"
      path = Rails.root.join("app/assets/images/mailer/#{image_file_name}")
      attachments.inline[image_file_name] = File.read(path)
    elsif source == "assets"
      path = Rails.root.join("app/assets/images/#{image_file_name}")
      attachments.inline[image_file_name] = File.read(path)
    end
  end

  def add_images
    add_image("brave-payments.png")
    add_image("logo-medium.png")
    add_image("logo-reddit.png")
    add_image("logo-rocketchat.png")
    add_image("logo-twitter.png")
    add_image("footer-top-pattern.png")
    add_image("logo-bat.png")

    if self.class == PromoMailer
      add_image("tweet.png", "assets")
      add_image("f-share.png", "assets")
      add_image("header-pattern-promo.png")
    elsif self.class == PublisherMailer
      add_image("header-pattern.png")
    end
  end

  def require_premailer
    require "premailer/rails"
  end
end
