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
    add_image("mailer/brave-rewards.png")
    add_image("mailer/social_bat.png")
    add_image("mailer/social_reddit.png")
    add_image("mailer/social_brave.png")
    add_image("mailer/social_twitter.png")

    raise "Invalid mailer class; can't run #add_images." unless self.class == InternalMailer || self.class == PromoMailer || self.class == PublisherMailer
    
  end

  def require_premailer
    require "premailer/rails"
  end

  # TODO Find a better way to do this
  def should_add_share_images?
    if (@_action_name == "new_channel_registered_2018q1") || (@_action_name == "promo_activated_2018q1_verified")
      return true
    else
      return false
    end
  end

  def should_add_ad_banners?
    if @_action_name == "promo_activated_2018q1_verified"
      return true
    else
      return false
    end
  end
end
