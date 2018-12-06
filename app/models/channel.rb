class Channel < ApplicationRecord
  has_paper_trail

  YOUTUBE = "youtube".freeze
  TWITCH = "twitch".freeze
  TWITTER = "twitter".freeze
  CONTEST_TIMEOUT = 10.days

  belongs_to :publisher
  belongs_to :details, polymorphic: true, validate: true, autosave: true, optional: false, dependent: :delete

  belongs_to :site_channel_details, -> { where( channels: { details_type: 'SiteChannelDetails' } )
                                             .includes( :channels ) }, foreign_key: 'details_id'

  belongs_to :youtube_channel_details, -> { where( channels: { details_type: 'YoutubeChannelDetails' } )
                                                .includes( :channels ) }, foreign_key: 'details_id'

  belongs_to :twitch_channel_details, -> { where( channels: { details_type: 'TwitchChannelDetails' } )
                                               .includes( :channels ) }, foreign_key: 'details_id'

  belongs_to :twitter_channel_details, -> { where( channels: { details_type: 'TwitterChannelDetails' } )
                                               .includes( :channels ) }, foreign_key: 'details_id'

  has_one :promo_registration, dependent: :destroy

  has_one :contesting_channel, class_name: "Channel", foreign_key: 'contested_by_channel_id'

  has_many :potential_payments

  belongs_to :contested_by_channel, class_name: "Channel"

  accepts_nested_attributes_for :details

  validates :publisher, presence: true

  validates :details, presence: true

  validate :details_not_changed?

  validates :verification_status, inclusion: { in: %w(failed awaiting_admin_approval approved_by_admin) }, allow_nil: true

  validates :verification_details, inclusion: {
    in: %w(domain_not_found connection_failed too_many_redirects no_txt_records token_incorrect_dns token_not_found_dns token_not_found_public_file no_https)
  }, allow_nil: true

  validate :site_channel_details_brave_publisher_id_unique_for_publisher, if: -> { details_type == 'SiteChannelDetails' }

  validate :verified_duplicate_channels_must_be_contested, if: -> { verified? }

  after_save :register_channel_for_promo, if: :should_register_channel_for_promo
  before_save :clear_verified_at_if_necessary

  before_destroy :preserve_contested_by_channels

  scope :site_channels, -> { joins(:site_channel_details) }
  scope :other_verified_site_channels, -> (id:) { site_channels.where(verified: true).where.not(id: id) }

  scope :youtube_channels, -> { joins(:youtube_channel_details) }
  scope :other_verified_youtube_channels, -> (id:) { youtube_channels.where(verified: true).where.not(id: id) }

  scope :twitch_channels, -> { joins(:twitch_channel_details) }
  scope :other_verified_twitch_channels, -> (id:) { twitch_channels.where(verified: true).where.not(id: id) }

  scope :twitter_channels, -> { joins(:twitter_channel_details) }
  scope :other_verified_twitter_channels, -> (id:) { twitter_channels.where(verified: true).where.not(id: id) }

  # Once the verification_method has been set it shows we have presented the publisher with the token. We need to
  # ensure this site_channel will be preserved so the publisher cna come back to it.
  scope :visible_site_channels, -> {
    site_channels.where('channels.verified = true or NOT site_channel_details.verification_method IS NULL')
  }
  scope :not_visible_site_channels, -> {
    site_channels.where(verified: [false, nil]).where(site_channel_details: {verification_method: nil})
  }
  scope :visible_youtube_channels, -> {
    youtube_channels.where.not('youtube_channel_details.youtube_channel_id': nil)
  }
  scope :visible_twitch_channels, -> {
    twitch_channels.where.not('twitch_channel_details.twitch_channel_id': nil)
  }
  scope :visible_twitter_channels, -> {
    twitch_channels.where.not('twitter_channel_details.twitter_channel_id': nil)
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
      when "twitter"
        visible_twitter_channels.where('twitch_channel_details.twitter_channel_id': identifier.split(":").last)
      else
        visible_site_channels.where('site_channel_details.brave_publisher_id': identifier)
    end
  }

  def self.statistical_totals
    {
      all_channels: Channel.verified.count,
      twitch: Channel.verified.twitch_channels.count,
      youtube:  Channel.verified.youtube_channels.count,
      site:  Channel.verified.site_channels.count
    }
  end

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
      self.details.youtube_channel_id
    when "SiteChannelDetails"
      self.details.brave_publisher_id
    when "TwitchChannelDetails"
      self.details.name
    when "TwitterChannelDetails"
      self.details.twitter_channel_id
    else
      nil
    end
  end

  # Returns the verified channel with the given channel identifier
  # e.g.
  # Channel.find_by_channel_identifier(channel.details.channel_identifier)
  # => <Channel id: "55ecd577-0425-420f-8796-78598b06c8a0",...,>
  def self.find_by_channel_identifier(channel_identifier)
    channel_id_split_on_prefix = channel_identifier.split(":", 2)
    channel_is_site_channel = channel_id_split_on_prefix.length == 1 # hack to identify site channels

    if channel_is_site_channel
      channel_details_type_identifier = channel_id_split_on_prefix.first
      return SiteChannelDetails.where(brave_publisher_id: channel_details_type_identifier).
                        joins(:channel).
                        where('channels.verified = true').first.channel
    end

    prefix = channel_id_split_on_prefix.first
    channel_details_type_identifier = channel_id_split_on_prefix.second
    case prefix
      when "youtube#channel"
        YoutubeChannelDetails.where(youtube_channel_id: channel_details_type_identifier).
                              joins(:channel).
                              where('channels.verified = true').first.channel
      when "twitch#channel"
        TwitchChannelDetails.where(name: channel_details_type_identifier).
                            joins(:channel).
                            where('channels.verified = true').first.channel
      when "twitch#author"
        TwitchChannelDetails.where(name: channel_details_type_identifier).
                            joins(:channel).
                            where('channels.verified = true').first.channel
      when "twitter#channel"
        TwitterChannelDetails.where(twitter_channel_id: channel_details_type_identifier).
                             joins(:channel).
                             where('channels.verified = true').first.channel
      else
        Rails.logger.info("Unable to find channel for channel identifier #{channel_identifier}")
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
        verification_status = "approved_by_admin"
      else
        errors.add(:base, "requires manual admin approval")
        return
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

  def self.search(query)
    query = query.downcase

    channel = Channel
              .joins(:publisher)
              .left_outer_joins(:site_channel_details)
              .left_outer_joins(:youtube_channel_details)
              .left_outer_joins(:twitch_channel_details)

    channel
      .where("lower(publishers.email) LIKE ?", query)
      .or(channel.where("lower(publishers.name) LIKE ?", query))
      .or(channel.where("lower(site_channel_details.brave_publisher_id) LIKE ?", query))
      .or(channel.where("lower(twitch_channel_details.twitch_channel_id) LIKE ?", query))
      .or(channel.where("lower(twitch_channel_details.display_name) LIKE ?", query))
      .or(channel.where("lower(twitch_channel_details.email) LIKE ?", query))
      .or(channel.where("lower(youtube_channel_details.youtube_channel_id) LIKE ?", query))
      .or(channel.where("lower(youtube_channel_details.title) LIKE ?", query))
      .or(channel.where("lower(youtube_channel_details.auth_email) LIKE ?", query))
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
    promo_running && publisher_enabled_promo && saved_change_to_verified? && verified
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

  def preserve_contested_by_channels
    if contesting_channel || verification_pending
      errors.add(:base, "contested_by_channel cannot be destroyed")
    end
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
      when "TwitterChannelDetails"
        Channel.other_verified_twitter_channels(id: self.id)
            .where(twitter_channel_details: { twitter_channel_id: self.details.twitter_channel_id })
    end

    if duplicate_verified_channels.any?
      if duplicate_verified_channels.count > 1
        errors.add(:base, "can only contest one channel")
      end

      contesting_channel = duplicate_verified_channels.first
      if (contesting_channel.contested_by_channel_id != self.id) && (contesting_channel.contested_by_channel_id != nil)
        errors.add(:base, "contesting channel does not match")
      end
    end
  end
end
