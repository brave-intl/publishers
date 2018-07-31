class Publisher < ApplicationRecord
  has_paper_trail
  self.per_page = 20

  UPHOLD_CODE_TIMEOUT = 5.minutes
  UPHOLD_ACCESS_PARAMS_TIMEOUT = 2.hours
  PROMO_STATS_UPDATE_DELAY = 10.minutes
  ADMIN = "admin"
  PUBLISHER = "publisher"
  ROLES = [ADMIN, PUBLISHER]
  JAVASCRIPT_DETECTED_RELEASE_TIME = "2018-06-19 22:51:51".freeze

  devise :timeoutable, :trackable, :omniauthable

  has_many :statements, -> { order('created_at DESC') }, class_name: 'PublisherStatement'
  has_many :u2f_registrations, -> { order("created_at DESC") }
  has_one :totp_registration
  has_many :login_activities

  has_many :channels, validate: true, autosave: true
  has_one :site_banner
  has_many :site_channel_details, through: :channels, source: :details, source_type: 'SiteChannelDetails'
  has_many :youtube_channel_details, through: :channels, source: :details, source_type: 'YoutubeChannelDetails'
  has_many :status_updates, -> { order(created_at: :desc) }, class_name: 'PublisherStatusUpdate'
  has_many :notes, class_name: 'PublisherNote', dependent: :destroy

  belongs_to :youtube_channel

  attr_encrypted :authentication_token, key: :encryption_key
  attr_encrypted :uphold_code, key: :encryption_key
  attr_encrypted :uphold_access_parameters, key: :encryption_key

  # Normalizes attribute before validation and saves into other attribute
  phony_normalize :phone, as: :phone_normalized, default_country_code: "US"

  validates :email, email: { strict_mode: true }, presence: true, unless: -> { pending_email.present? }
  validates :email, uniqueness: {case_sensitive: false}, allow_nil: true
  validates :pending_email, email: { strict_mode: true }, presence: true, if: -> { email.blank? }
  validate :pending_email_must_be_a_change
  validate :pending_email_can_not_be_in_use

  # validates :name, presence: true, if: -> { brave_publisher_id.present? }
  validates :phone_normalized, phony_plausible: true

  # uphold_code is an intermediate step to acquiring uphold_access_parameters
  # and should be cleared once it has been used to get uphold_access_parameters
  validates :uphold_code, absence: true, if: -> { uphold_access_parameters.present? || uphold_verified? }
  before_validation :set_uphold_updated_at, if: -> {
    uphold_code_changed? || uphold_access_parameters_changed? || uphold_state_token_changed?
  }

  # uphold_access_parameters should be cleared once uphold_verified has been set
  # (see `verify_uphold` method below)
  validates :uphold_access_parameters, absence: true, if: -> { uphold_verified? }

  validates :promo_token_2018q1, uniqueness: true,  allow_nil: true

  before_create :build_default_channel
  before_destroy :dont_destroy_publishers_with_channels

  scope :by_email_case_insensitive, -> (email_to_find) { where('lower(publishers.email) = :email_to_find', email_to_find: email_to_find.downcase) }

  after_create :set_created_status
  after_update :set_onboarding_status, if: -> { email.present? && email_before_last_save.nil? }
  after_update :set_active_status, if: -> { saved_change_to_two_factor_prompted_at? && two_factor_prompted_at_before_last_save.nil? }

  after_save :set_promo_stats_updated_at_2018q1, if: -> { saved_change_to_promo_stats_2018q1? }

  scope :created_recently, -> { where("created_at > :start_date", start_date: 1.week.ago) }

  scope :email_verified, -> { where.not(email: nil) }
  scope :not_admin, -> { where.not(role: ADMIN) }
  scope :suspended, -> {
    joins(:status_updates)
    .where('publisher_status_updates.created_at =
            (SELECT MAX(publisher_status_updates.created_at)
            FROM publisher_status_updates
            WHERE publisher_status_updates.publisher_id = publishers.id)')
    .where("publisher_status_updates.status = 'suspended'")
  }

  scope :not_suspended, -> {
    where.not(id: suspended)
  }

  # publishers that have uphold codes that have been sitting for five minutes
  # can be cleared if publishers do not create wallet within 5 minute window
  scope :has_stale_uphold_code, -> {
    where.not(encrypted_uphold_code: nil)
    .where("uphold_updated_at < ?", UPHOLD_CODE_TIMEOUT.ago)
  }

  # publishers that have access params that havent accepted by eyeshade
  # can be cleared after 2 hours
  scope :has_stale_uphold_access_parameters, -> {
    where.not(encrypted_uphold_access_parameters: nil)
    .where("uphold_updated_at < ?", UPHOLD_ACCESS_PARAMS_TIMEOUT.ago)
  }

  scope :with_verified_channel, -> {
    joins(:channels).where('channels.verified = true').distinct
  }

  # API call to eyeshade
  def wallet
    return @_wallet if @_wallet

    @_wallet = PublisherWalletGetter.new(publisher: self).perform

    # if the wallet call fails the wallet will be nil
    if @_wallet
      # Sync the default_currency to eyeshade, if they are mismatched
      # ToDo: This can be eliminated once eyeshade no longer maintains a default_currency
      # (which should be after publishers is driving payout report generation)
      if self.default_currency.present? && self.default_currency != @_wallet.default_currency
        UploadDefaultCurrencyJob.perform_later(publisher_id: self.id)
      end
    end
    @_wallet
  end

  def encryption_key
    Publisher.encryption_key
  end

  def email_verified?
    email.present?
  end

  def suspended?
    last_status_update.present? && last_status_update.status == PublisherStatusUpdate::SUSPENDED
  end

  def verified?
    email_verified? && name.present? && agreed_to_tos.present?
  end

  def to_s
    name
  end

  def prepare_uphold_state_token
    if self.uphold_state_token.nil?
      self.uphold_state_token = SecureRandom.hex(64)
      save!
    end
  end

  def receive_uphold_code(code)
    self.uphold_state_token = nil
    self.uphold_code = code
    self.uphold_access_parameters = nil
    self.uphold_verified = false
    save!
  end

  def verify_uphold
    self.uphold_state_token = nil
    self.uphold_code = nil
    self.uphold_access_parameters = nil
    self.uphold_verified = true
    save!
  end

  def disconnect_uphold
    self.uphold_code = nil
    self.uphold_access_parameters = nil
    self.uphold_verified = false
    save!
  end

  def uphold_reauthorization_needed?
    self.uphold_verified? &&
      self.wallet.present? &&
      ['re-authorize', 'authorize'].include?(self.wallet.action)
  end

  def uphold_incomplete?
    self.uphold_verified? && self.wallet.present? && !self.wallet.authorized?
  end

  def uphold_status
    if self.uphold_verified?
      if self.uphold_reauthorization_needed?
        :reauthorization_needed
      elsif self.uphold_incomplete?
        :incomplete
      else
        :verified
      end
    elsif self.uphold_access_parameters.present?
      :access_parameters_acquired
    elsif self.uphold_code.present?
      :code_acquired
    else
      :unconnected
    end
  end

  def uphold_processing?
    self.uphold_access_parameters.present? || self.uphold_code.present?
  end

  def set_uphold_updated_at
    self.uphold_updated_at = Time.now
  end

  def owner_identifier
    "publishers#uuid:#{id}"
  end

  def promo_status(promo_running)
    if !promo_running
      :over
    elsif self.promo_enabled_2018q1
      :active
    else
      :inactive
    end
  end

  def promo_stats_status
    promo_disabled = !self.promo_enabled_2018q1
    has_no_promo_enabled_channels = !self.channels.joins(:promo_registration).where.not(promo_registrations: {referral_code: nil}).any?
    if promo_disabled || has_no_promo_enabled_channels
      :disabled
    elsif self.promo_stats_updated_at_2018q1.nil? || self.promo_stats_updated_at_2018q1 < PROMO_STATS_UPDATE_DELAY.ago
      :update
    else
      :updated
    end
  end

  def set_promo_stats_updated_at_2018q1
    update_column(:promo_stats_updated_at_2018q1, Time.now)
  end

  def has_verified_channel?
    channels.any?(&:verified?)
  end

  def admin?
    role == ADMIN
  end

  def publisher?
    role == PUBLISHER
  end

  def inferred_status
    return last_status_update.status if last_status_update.present?
    if verified?
      return PublisherStatusUpdate::ACTIVE
    else
      return PublisherStatusUpdate::ONBOARDING
    end
  end

  def last_status_update
    status_updates.first
  end

  def last_login_activity
    login_activity = login_activities.last
  end

  def can_create_uphold_cards?
    uphold_verified? &&
      wallet.present? &&
      wallet.authorized? &&
      wallet.scope &&
      wallet.scope.include?("cards:write") &&
      !excluded_from_payout
  end

  # (Albert Wang) We can remove this when beta is done
  def in_brave_rewards_whitelist?
    self.email.in?((Rails.application.secrets[:brave_rewards_email_whitelist] || "").split(","))
  end

  private

  def set_created_status
    created_publisher_status_update = PublisherStatusUpdate.new(publisher: self, status: "created")
    created_publisher_status_update.save!
  end

  def set_onboarding_status
    onboarding_publisher_status_update = PublisherStatusUpdate.new(publisher: self, status: "onboarding")
    onboarding_publisher_status_update.save!
  end

  def set_active_status
    if two_factor_prompted_at.nil? || agreed_to_tos.nil?
      raise "Publisher must have agreed to TOS and addressed 2fa prompt to be active"
    else
      active_publisher_status_update = PublisherStatusUpdate.new(publisher: self, status: "active")
      active_publisher_status_update.save!
    end
  end

  def dont_destroy_publishers_with_channels
    if channels.count > 0
      errors.add(:base, "cannot delete publisher while channels exist")
      throw :abort
    end
  end

  def build_default_channel
    channel = Channel.new
    channel.publisher = self
    true
  end

  def pending_email_must_be_a_change
    if pending_email == email
      errors.add(:pending_email, "is not a change")
    end
  end

  def pending_email_can_not_be_in_use
    if pending_email && self.class.where(email: pending_email).count > 0
      errors.add(:pending_email, "is taken")
    end
  end

  class << self
    def encryption_key
      Rails.application.secrets[:attr_encrypted_key]
    end
  end
end
