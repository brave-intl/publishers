class Channel < ApplicationRecord
  has_paper_trail

  belongs_to :publisher
  belongs_to :details, polymorphic: true, validate: true, autosave: true, optional: false, dependent: :delete

  belongs_to :site_channel_details, -> { where( channels: { details_type: 'SiteChannelDetails' } )
                                             .includes( :channels ) }, foreign_key: 'details_id'

  belongs_to :youtube_channel_details, -> { where( channels: { details_type: 'YoutubeChannelDetails' } )
                                                .includes( :channels ) }, foreign_key: 'details_id'

  belongs_to :twitch_channel_details, -> { where( channels: { details_type: 'TwitchChannelDetails' } )
                                               .includes( :channels ) }, foreign_key: 'details_id'

  has_one :promo_registration, dependent: :destroy

  accepts_nested_attributes_for :details

  validate :details_not_changed?

  after_save :register_channel_for_promo, if: :should_register_channel_for_promo

  scope :site_channels, -> { joins(:site_channel_details) }
  scope :youtube_channels, -> { joins(:youtube_channel_details) }
  scope :twitch_channels, -> { joins(:twitch_channel_details) }

  # Once the verification_method has been set it shows we have presented the publisher with the token. We need to
  # ensure this site_channel will be preserved so the publisher cna come back to it.
  scope :visible_site_channels, -> {
    site_channels.where('channels.verified = true or NOT site_channel_details.verification_method IS NULL')
  }
  scope :visible_youtube_channels, -> {
    youtube_channels.where.not('youtube_channel_details.youtube_channel_id': nil)
  }
  scope :visible_twitch_channels, -> {
    twitch_channels.where.not('twitch_channel_details.twitch_channel_id': nil)
  }
  scope :visible, -> {
    left_outer_joins(:site_channel_details).
        where('channels.verified = true or NOT site_channel_details.verification_method IS NULL')
  }

  scope :verified, -> { where(verified: true) }

  scope :by_channel_identifier, -> (identifier) {
    case identifier.split("#")[0]
      when "twitch"
        visible_twitch_channels.where('twitch_channel_details.twitch_channel_id': identifier.split(":").last)
      when "youtube"
        visible_youtube_channels.where('youtube_channel_details.youtube_channel_id': identifier.split(":").last)
      else
        visible_site_channels.where('site_channel_details.brave_publisher_id': identifier)
    end
  }

  def publication_title
    details.publication_title
  end

  def details_not_changed?
    unless details_id_was.nil? || (details_id == details_id_was && details_type == details_type_was)
      errors.add(:details, "can't be changed")
    end
  end

  def channel_id
    channel_type = self.details_type
    case channel_type
    when "YoutubeChannelDetails"
      return self.details.youtube_channel_id
    when "SiteChannelDetails"
      return self.details.brave_publisher_id
    else
      nil
    end
  end

  def promo_enabled?
    if self.promo_registration.present?
      if self.promo_registration.referral_code.present?
        return true
      end
    end
    false
  end

  private

  def should_register_channel_for_promo
    promo_running = Rails.application.secrets[:active_promo_id].present?  # Could use PromosHelper#active_promo_id
    publisher_enabled_promo = self.publisher.promo_enabled_2018q1?
    promo_running && publisher_enabled_promo && verified_changed? && verified
  end

  def register_channel_for_promo
    RegisterChannelForPromoJob.new.perform(channel: self)
  end
end
