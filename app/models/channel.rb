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

  has_one :contesting_channel, class_name: "Channel", foreign_key: 'contested_by_channel_id'

  belongs_to :contested_by_channel, class_name: "Channel"

  accepts_nested_attributes_for :details

  validates :publisher, presence: true

  validates :details, presence: true

  validate :details_not_changed?

  validates :verification_status, inclusion: { in: %w(started failed awaiting_admin_approval) }, allow_nil: true

  validate :site_channel_details_brave_publisher_id_unique_for_publisher, if: -> { details_type == 'SiteChannelDetails' }

  validate :verified_duplicate_channels_must_be_contested, unless: -> { verified? || self.id.nil? }

  # Sensitive channels require manual admin approval to verify.
  validate :verification_restriction_ok

  after_save :register_channel_for_promo, if: :should_register_channel_for_promo
  before_save :clear_verified_at_if_necessary

  # Set this to true prior to save to signnify admin approval.
  attr_accessor :verification_admin_approval

  around_destroy :coordinate_contested_channel_destory

  scope :site_channels, -> { joins(:site_channel_details) }
  scope :other_verified_site_channels, -> (id:) { site_channels.where(verified: true).where.not(id: id) }

  scope :youtube_channels, -> { joins(:youtube_channel_details) }
  scope :other_verified_youtube_channels, -> (id:) { youtube_channels.where(verified: true).where.not(id: id) }

  scope :twitch_channels, -> { joins(:twitch_channel_details) }
  scope :other_verified_twitch_channels, -> (id:) { twitch_channels.where(verified: true).where.not(id: id) }

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
        where('(channels.verified = true or channels.verification_pending) or NOT site_channel_details.verification_method IS NULL')
  }

  scope :contested_channels_ready_to_transfer, -> {
    where.not(contested_by_channel_id: nil).where("contest_timesout_at < ?", Time.now)
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

  # NOTE This method is should only be used in referral promo logic. Use {channel}.details.channel_identifier for everything else.
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

  def verification_started!
    update!(verified: false, verification_status: 'started', verification_details: nil)
  end

  def verification_failed!(details = nil)
    # Clear changes so we don't bypass validations when saving without checking them
    self.reload

    self.verified = false
    self.verified_at = nil
    self.verification_status = 'failed'
    self.verification_details = details
    self.save!(validate: false)
  end

  def verification_awaiting_admin_approval!
    update!(verified: false, verification_status: 'awaiting_admin_approval', verification_details: nil)
  end

  def verification_succeeded!
    update!(verified: true, verification_status: nil, verification_details: nil, verified_at: Time.now)
  end

  def verification_started?
    self.verification_status == 'started'
  end

  def verification_failed?
    self.verification_status == 'failed'
  end

  def verification_awaiting_admin_approval?
    self.verification_status == 'awaiting_admin_approval'
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
    duplicate_unverified_channels = publisher.channels.visible_site_channels
                                                     .where(site_channel_details: { brave_publisher_id: self.details.brave_publisher_id })
                                                     .where.not(id: id)

    if duplicate_unverified_channels.any?
      errors.add(:brave_publisher_id, "must be unique")
    end
  end

  def coordinate_contested_channel_destory
    if contested_by_channel
      # Deleting a channel that is being contested. This will free up the channel that's contesting for approval
      c = contested_by_channel
      # ToDo: Approve c
    elsif contesting_channel
      # Deleting the channel that's contesting. This should be equivalent to rejecting the transfer
      c = contesting_channel
      c.contested_by_channel = nil
      c.save!

      # ToDo: Send email noting that channel contest has been rejected
      # Email should probably happen after yield
    end

    yield

  end

  def verified_duplicate_channels_must_be_contested
    duplicate_verified_channels = case details_type
      when "SiteChannelDetails"
        Channel.other_verified_site_channels(id: self.id)
            .where(site_channel_details: { brave_publisher_id: self.details.brave_publisher_id })
      when "YoutubeChannelDetails"
        Channel.other_verified_youtube_channels(id: self.id)
            .where(youtube_channel_details: { youtube_channel_id: self.details.youtube_channel_id })
      when "TwitchChannelDetails"
        Channel.other_verified_twitch_channels(id: self.id)
            .where(twitch_channel_details: { twitch_channel_id: self.details.twitch_channel_id })
    end

    if duplicate_verified_channels.any?
      if duplicate_verified_channels.count > 1
        errors.add(:base, "can only contest one channel")
      end

      contesting_channel = duplicate_verified_channels.first
      if contesting_channel.contested_by_channel_id != self.id
        errors.add(:base, "contesting channel does not match")
      end

      if contesting_channel.contest_token.nil?
        errors.add(:base, "contesting channel does not have a token")
      end

      if contesting_channel.contest_timesout_at.nil?
        errors.add(:base, "contesting channel does not have a timeout")
      end
    end
  end

  # Sensitive channels require manual admin approval to verify.
  # TODO: Create a better admin verification workflow.
  def verification_restriction_ok
    require "publishers/restricted_channels"

    if !verified? || !verified_changed? || !Publishers::RestrictedChannels.restricted?(self)
      return true
    end
    if !verification_admin_approval
      errors.add(:verified, VERIFICATION_RESTRICTION_ERROR)
    end
  end
end
