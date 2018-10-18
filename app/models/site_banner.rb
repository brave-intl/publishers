require 'rubygems'
require 'json'

class SiteBanner < ApplicationRecord
  include Rails.application.routes.url_helpers
  has_one_attached :logo
  has_one_attached :background_image
  belongs_to :publisher

  LOGO = "logo".freeze
  LOGO_DIMENSIONS = [480,480]
  LOGO_UNIVERSAL_FILE_SIZE = 40_000 # In bytes

  BACKGROUND = "background".freeze
  BACKGROUND_DIMENSIONS = [900,176]
  BACKGROUND_UNIVERSAL_FILE_SIZE = 70_000 # In bytes

  NUMBER_OF_DONATION_AMOUNTS = 3
  MAX_DONATION_AMOUNT = 20

  validates_presence_of :title, :description, :donation_amounts, :default_donation, :publisher
  validate :donation_amounts_in_scope

  #####################################################
  # Validations
  #####################################################

  def donation_amounts_in_scope
    return if errors.present? # Don't bother checking against donation amounts if donation amounts are nil
    errors.add(:base, "Must have #{NUMBER_OF_DONATION_AMOUNTS} donation amounts") if donation_amounts.count != NUMBER_OF_DONATION_AMOUNTS
    errors.add(:base, "A donation amount is zero or negative") if donation_amounts.select { |donation_amount| donation_amount <= 0}.count > 0
    errors.add(:base, "A donation amount is above a target threshold") if donation_amounts.select { |donation_amount| donation_amount >= MAX_DONATION_AMOUNT}.count > 0
  end

  #####################################################
  # Methods
  #####################################################

  def read_only_react_property
    {
      title: self.title,
      description: self.description,
      backgroundUrl: url_for(self.background_image),
      logoUrl: url_for(self.logo),
      donationAmounts: self.donation_amounts,
      socialLinks: self.social_links
    }
  end

  def url_for(object)
    return nil if object.nil? || object.attachment.nil?

    if Rails.env.development? || Rails.env.test?
      # (Albert Wang): I couldn't figure out how to play nicely with localhost
      "https://0.0.0.0:3000" + rails_blob_path(object, only_path: true)
    else
      "#{Rails.application.secrets[:s3_rewards_public_domain]}/#{object.blob.key}"
    end
  end
end
