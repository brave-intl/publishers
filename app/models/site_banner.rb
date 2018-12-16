require 'rubygems'
require 'json'
include ActionView::Helpers::SanitizeHelper

class SiteBanner < ApplicationRecord
  include Rails.application.routes.url_helpers
  has_one_attached :logo
  has_one_attached :background_image
  belongs_to :publisher

  LOGO = "logo".freeze
  LOGO_DIMENSIONS = [480,480]
  LOGO_UNIVERSAL_FILE_SIZE = 40_000 # In bytes

  BACKGROUND = "background".freeze
  BACKGROUND_DIMENSIONS = [2700,528]
  BACKGROUND_UNIVERSAL_FILE_SIZE = 120_000 # In bytes

  NUMBER_OF_DONATION_AMOUNTS = 3
  DONATION_AMOUNT_PRESETS = ['1,5,10', '5,10,20', '10,20,50', '20,50,100', '50,100,500']
  MAX_DONATION_AMOUNT = 999

  validates_presence_of :title, :description, :donation_amounts, :default_donation, :publisher
  validate :donation_amounts_in_scope
  before_save :clear_invalid_social_links

  def donation_amounts_in_scope
    return if errors.present? # Don't bother checking against donation amounts if donation amounts are nil
    errors.add(:base, "Must have #{NUMBER_OF_DONATION_AMOUNTS} donation amounts") if donation_amounts.count != NUMBER_OF_DONATION_AMOUNTS
    errors.add(:base, "A donation amount is zero or negative") if donation_amounts.select { |donation_amount| donation_amount <= 0}.count > 0
    errors.add(:base, "A donation amount is above a target threshold") if donation_amounts.select { |donation_amount| donation_amount >= MAX_DONATION_AMOUNT}.count > 0
    errors.add(:base, "Must be an approved tip preset") unless DONATION_AMOUNT_PRESETS.include? donation_amounts.join(',')
  end

  # (Albert Wang) Until the front end can properly handle errors, let's not block save and only clear invalid domains
  def clear_invalid_social_links
    return if errors.present? || social_links.nil?
    require 'addressable'
    self.social_links = self.social_links.select { |key,_| key.in?(["twitch", "youtube", "twitter"]) }

    unless self.social_links["twitch"].blank? || Addressable::URI.parse(self.social_links["twitch"]).normalize.host.in?(["www.twitch.tv", "twitch.tv"])
      self.social_links["twitch"] = ""
    end

    unless self.social_links["youtube"].blank? || Addressable::URI.parse(self.social_links["youtube"]).normalize.host.in?(["www.youtube.com", "youtube.com"])
      self.social_links["youtube"] = ""
    end

    unless self.social_links["twitter"].blank? || Addressable::URI.parse(self.social_links["twitter"]).normalize.host.in?(["www.twitter.com", "twitter.com"])
      self.social_links["twitter"] = ""
    end
  end

  #####################################################
  # Methods
  #####################################################

  def self.new_helper(publisher_id, channel_id)
    headline = I18n.t 'banner.headline'
    tagline = I18n.t 'banner.tagline'
    SiteBanner.create(
      publisher_id: publisher_id,
      channel_id: channel_id,
      title: headline,
      description: tagline,
      donation_amounts: [1, 5, 10],
      default_donation: 5,
      social_links: {youtube: '', twitter: '', twitch: ''}
    )
  end

  def update_helper(title, description, donation_amounts, social_links)
    self.update(
      title: sanitize(title),
      description: sanitize(description),
      donation_amounts: JSON.parse(sanitize(donation_amounts)),
      default_donation: JSON.parse(sanitize(donation_amounts)).second,
      social_links: social_links.present? ? JSON.parse(sanitize(social_links)) : {}
    )
  end

  def read_only_react_property
    {
      channel_id: self.channel_id,
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
