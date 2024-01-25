# typed: ignore

require "addressable"

class SiteBanner < ApplicationRecord
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::SanitizeHelper

  has_one_attached :logo, service: :amazon_public_bucket
  has_one_attached :background_image, service: :amazon_public_bucket

  belongs_to :publisher
  belongs_to :channel

  LOGO = "logo".freeze
  LOGO_DIMENSIONS = [480, 480].freeze
  LOGO_UNIVERSAL_FILE_SIZE = 40_000 # In bytes

  BACKGROUND = "background".freeze
  BACKGROUND_DIMENSIONS = [2700, 528].freeze
  BACKGROUND_UNIVERSAL_FILE_SIZE = 120_000 # In bytes

  DEFAULT_TITLE = I18n.t("banner.headline")
  DEFAULT_DESCRIPTION = I18n.t("banner.tagline")

  validates_presence_of :title, :description, :publisher
  before_save :clear_invalid_social_links
  after_save :update_site_banner_lookup!

  def update_site_banner_lookup!
    if channel.present?
      channel.update_site_banner_lookup!
    else
      publisher.update_site_banner_lookup!
    end
  end

  # (Albert Wang) Until the front end can properly handle errors, let's not block save and only clear invalid domains
  def clear_invalid_social_links
    return if errors.present? || social_links.nil?
    self.social_links = social_links.select { |key, _| key.in?(["twitch", "youtube", "twitter", "github", "reddit", "vimeo"]) }

    unless social_links["twitch"].blank? || Addressable::URI.parse(social_links["twitch"]).to_s.starts_with?("https://www.twitch.tv/", "https://twitch.tv/", "www.twitch.tv/", "twitch.tv/")
      social_links["twitch"] = ""
    end

    unless social_links["youtube"].blank? || Addressable::URI.parse(social_links["youtube"]).to_s.starts_with?("https://www.youtube.com/", "https://youtube.com/", "www.youtube.com/", "youtube.com/")
      social_links["youtube"] = ""
    end

    unless social_links["twitter"].blank? || Addressable::URI.parse(social_links["twitter"]).to_s.starts_with?("https://www.twitter.com/", "https://twitter.com/", "www.twitter.com/", "twitter.com/")
      social_links["twitter"] = ""
    end

    unless social_links["github"].blank? || Addressable::URI.parse(social_links["github"]).to_s.starts_with?("https://www.github.com/", "https://github.com/", "www.github.com/", "github.com/")
      social_links["github"] = ""
    end

    unless social_links["reddit"].blank? || Addressable::URI.parse(social_links["reddit"]).to_s.starts_with?("https://www.reddit.com/", "https://reddit.com/", "www.reddit.com/", "reddit.com/")
      social_links["reddit"] = ""
    end

    unless social_links["vimeo"].blank? || Addressable::URI.parse(social_links["vimeo"]).to_s.starts_with?("https://www.vimeo.com/", "https://vimeo.com/", "www.vimeo.com/", "vimeo.com/")
      social_links["vimeo"] = ""
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
      social_links: {youtube: "", twitter: "", twitch: "", github: "", reddit: "", vimeo: ""}
    )
  end

  def update_helper(title, description, social_links)
    update(
      title: sanitize(title),
      description: sanitize(description),
      social_links: social_links.present? ? JSON.parse(sanitize(social_links)) : {}
    )
  end

  def read_only_react_property
    {
      title: title,
      description: description,
      backgroundUrl: pcdn_public_image_url(background_image),
      logoUrl: pcdn_public_image_url(logo),
      socialLinks: social_links
    }
  end

  def pcdn_public_image_url(image)
    if image&.blob&.key
      if image&.blob&.filename.to_s.end_with?("padded")
        "#{Rails.configuration.pub_secrets[:s3_rewards_public_domain]}/#{image&.blob&.key}.jpg.pad"
      else
        "#{Rails.configuration.pub_secrets[:s3_rewards_public_domain]}/#{image&.blob&.key}"
      end
    else
      ""
    end
  end

  def non_default_properties
    properties = read_only_react_property
    # Remove properties that are considered the "Default". The client will handle parsing for this.
    properties.delete(:description) if properties[:description].eql?(DEFAULT_DESCRIPTION)
    properties.delete(:title) if properties[:title].eql?(DEFAULT_TITLE)
    properties[:socialLinks]&.delete_if { |k, v| v.blank? }

    properties.delete_if { |k, v| v.blank? && !(k == :backgroundUrl || k == :logoUrl) }

    properties
  end
end
