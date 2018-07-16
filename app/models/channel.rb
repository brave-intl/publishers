class Channel < ApplicationRecord
  has_paper_trail

  VERIFICATION_RESTRICTION_ERROR = "requires manual admin approval"

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

  validates :publisher, presence: true

  validates :details, presence: true

  validate :details_not_changed?

  validates :verification_status, inclusion: { in: %w(failed awaiting_admin_approval approved_by_admin) }, allow_nil: true

  validates :verification_details, inclusion: {
    in: %w(domain_not_found connection_failed too_many_redirects no_txt_records token_incorrect_dns token_not_found_dns token_not_found_public_file no_https)
  }, allow_nil: true

  validate :site_channel_details_brave_publisher_id_unique_for_publisher, if: -> { details_type == 'SiteChannelDetails' }

  after_save :register_channel_for_promo, if: :should_register_channel_for_promo
  before_save :clear_verified_at_if_necessary

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

  #########################
  ## Constants
  #########################

  YOUTUBE = "youtube".freeze
  TWITCH = "twitch".freeze

  def publication_title
    details.publication_title
  end

  def details_not_changed?
    unless details_id_was.nil? || (details_id == details_id_was && details_type == details_type_was)
      errors.add(:details, "can't be changed")
    end
  end

  # NOTE This method is should only be used in referral promo logic. Use {channel}.details.channel_identifer for everything else.
  # This will return the channel_identifier without the youtube#channel: or twitch#channel: prefix
  def channel_id
    channel_type = self.details_type
    case channel_type
    when "YoutubeChannelDetails"
      return self.details.youtube_channel_id
    when "SiteChannelDetails"
      return self.details.brave_publisher_id
    when "TwitchChannelDetails"
      return self.details.name
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

  def verification_failed!(details = nil)
    # Clear changes so we don't bypass validations when saving without checking them
    self.reload

    self.verified = false
    self.verified_at = nil
    self.verification_status = 'failed'
    self.verification_details = details
    self.save!
  end

  def verification_awaiting_admin_approval!
    update!(verified: false, verification_status: 'awaiting_admin_approval', verification_details: nil)
  end

  def verification_succeeded!(has_admin_approval)
    if needs_admin_approval?
      if has_admin_approval
        verification_status = 'approved_by_admin'
      else
        raise VERIFICATION_RESTRICTION_ERROR
      end
    else
      verification_status = nil
    end
    
    update!(verified: true, verification_status: verification_status, verification_details: nil, verified_at: Time.now)
  end

  def needs_admin_approval?
    require "publishers/restricted_channels"
    Publishers::RestrictedChannels.restricted?(self)
  end

  def verification_failed?
    self.verification_status == 'failed'
  end

  def verification_awaiting_admin_approval?
    self.verification_status == 'awaiting_admin_approval'
  end

  def verification_approved_by_admin?
    self.verification_status == 'approved_by_admin'
  end

  def update_last_verification_timestamp
    # Used for caching on the api/public/channels#timestamp
    Rails.cache.set("last_updated_channel_timestamp", Time.now.to_i << 32)
  end

  private

  def should_register_channel_for_promo
    promo_running = Rails.application.secrets[:active_promo_id].present?  # Could use PromosHelper#active_promo_id
    publisher_enabled_promo = self.publisher.promo_enabled_2018q1?
    promo_running && publisher_enabled_promo && verified_changed? && verified
  end

  def clear_verified_at_if_necessary
    self.verified_at = nil if self.verified == false && self.verified_at.present?
  end

  def register_channel_for_promo
    RegisterChannelForPromoJob.new.perform(channel: self)
  end

  def site_channel_details_brave_publisher_id_unique_for_publisher

    dupicate_unverified_channels = publisher.channels.visible_site_channels
                                                     .where(site_channel_details: { brave_publisher_id: self.details.brave_publisher_id })
                                                     .where.not(id: id)

    if dupicate_unverified_channels.any?
      errors.add(:brave_publisher_id, "must be unique")
    end
  end
end
