# typed: ignore

class ApplicationMailer < ActionMailer::Base
  INTERNAL_EMAIL = Rails.configuration.pub_secrets[:internal_email].freeze
  BIZDEV_EMAIL = Rails.configuration.pub_secrets[:bizdev_email].freeze
  PAYOUT_CONTACT_EMAIL = Rails.configuration.pub_secrets[:payout_contact_email].freeze
  BRAND_BIDDING_EMAIL = Rails.configuration.pub_secrets[:brand_bidding_email].freeze

  default from: Rails.configuration.pub_secrets[:from_email]
  layout "mailer"

  before_action :require_premailer
  before_action :add_images, unless: -> { instance_of?(InternalMailer) }

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
  end

  def require_premailer
    require "premailer/rails"
  end
end
