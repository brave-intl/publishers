require 'addressable'

class SiteBanner < ApplicationRecord
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::SanitizeHelper
  include PublicS3

  has_one_public_s3 :logo

  has_one_public_s3 :background_image
  belongs_to :publisher
  belongs_to :channel

  LOGO = "logo".freeze
  LOGO_DIMENSIONS = [480, 480].freeze
  LOGO_UNIVERSAL_FILE_SIZE = 40_000 # In bytes

  BACKGROUND = "background".freeze
  BACKGROUND_DIMENSIONS = [2700, 528].freeze
  BACKGROUND_UNIVERSAL_FILE_SIZE = 120_000 # In bytes

  NUMBER_OF_DONATION_AMOUNTS = 3
  DONATION_AMOUNT_PRESETS = ['1,5,10', '5,10,20', '10,20,50', '20,50,100'].freeze
  MAX_DONATION_AMOUNT = 999

  DEFAULT_TITLE = I18n.t('banner.headline')
  DEFAULT_DESCRIPTION = I18n.t('banner.tagline')
  DEFAULT_AMOUNTS = [1, 5, 10].freeze

  validates_presence_of :title, :description, :donation_amounts, :default_donation, :publisher
  validate :donation_amounts_in_scope
  before_save :clear_invalid_social_links

  def donation_amounts_in_scope
    return if errors.present?
    errors.add(:base, "Must be an approved tip preset") unless DONATION_AMOUNT_PRESETS.include? donation_amounts.join(',')
  end

  # (Albert Wang) Until the front end can properly handle errors, let's not block save and only clear invalid domains
  def clear_invalid_social_links
    return if errors.present? || social_links.nil?
    self.social_links = social_links.select { |key, _| key.in?(["twitch", "youtube", "twitter"]) }

    unless social_links["twitch"].blank? || Addressable::URI.parse(social_links["twitch"]).to_s.starts_with?('https://www.twitch.tv/', 'https://twitch.tv/', 'www.twitch.tv/', 'twitch.tv/')
      social_links["twitch"] = ""
    end

    unless social_links["youtube"].blank? || Addressable::URI.parse(social_links["youtube"]).to_s.starts_with?('https://www.youtube.com/', 'https://youtube.com/', 'www.youtube.com/', 'youtube.com/')
      social_links["youtube"] = ""
    end

    unless social_links["twitter"].blank? || Addressable::URI.parse(social_links["twitter"]).to_s.starts_with?('https://www.twitter.com/', 'https://twitter.com/', 'www.twitter.com/', 'twitter.com/')
      social_links["twitter"] = ""
    end
  end

  #####################################################
  # Methods
  #####################################################

  def self.new_helper(publisher_id, channel_id)
    SiteBanner.create(
      publisher_id: publisher_id,
      channel_id: channel_id,
      title: DEFAULT_TITLE,
      description: DEFAULT_DESCRIPTION,
      donation_amounts: DEFAULT_AMOUNTS,
      default_donation: 5,
      social_links: { youtube: '', twitter: '', twitch: '' }
    )
  end

  def update_helper(title, description, donation_amounts, social_links)
    update(
      title: sanitize(title),
      description: sanitize(description),
      donation_amounts: JSON.parse(sanitize(donation_amounts)),
      default_donation: JSON.parse(sanitize(donation_amounts)).second,
      social_links: social_links.present? ? JSON.parse(sanitize(social_links)) : {}
    )
  end

  def read_only_react_property
    properties = {
      title: title,
      description: description,
      backgroundUrl: public_background_image_url,
      logoUrl: public_logo_url,
      donationAmounts: donation_amounts,
      socialLinks: social_links,
    }

    # Remove properties that are considered the "Default". The client will handle parsing for this.
    properties.delete(:description) if properties[:description].eql?(DEFAULT_DESCRIPTION)
    properties.delete(:title) if properties[:title].eql?(DEFAULT_TITLE)
    properties.delete(:donationAmounts) if properties[:donationAmounts].eql?(DEFAULT_AMOUNTS)
    properties[:socialLinks]&.delete_if { |k, v| v.blank? }

    properties.delete_if { |k, v| v.blank? }

    properties
  end
end
