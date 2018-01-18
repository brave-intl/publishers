class Publisher < ApplicationRecord
  has_paper_trail

  UPHOLD_CODE_TIMEOUT = 5.minutes
  UPHOLD_ACCESS_PARAMS_TIMEOUT = 2.hours
  
  has_many :statements, -> { order('created_at DESC') }, class_name: 'PublisherStatement'
  has_many :u2f_registrations, -> { order("created_at DESC") }
  has_one :totp_registration

  attr_encrypted :authentication_token, key: :encryption_key
  attr_encrypted :uphold_code, key: :encryption_key
  attr_encrypted :uphold_access_parameters, key: :encryption_key

  devise :timeoutable, :trackable, :omniauthable

  # Normalizes attribute before validation and saves into other attribute
  phony_normalize :phone, as: :phone_normalized, default_country_code: "US"

  validates :email, email: { strict_mode: true }, presence: true, if: -> { brave_publisher_id.present? }
  validates :pending_email, email: { strict_mode: true }, presence: true, if: -> { email.blank? }
  validates :name, presence: true, if: -> { brave_publisher_id.present? }
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

  # brave_publisher_id is a normalized identifier provided by ledger API
  # It is like base domain (eTLD + left part) but may include additional
  # formats to support more publishers.
  validates :brave_publisher_id, uniqueness: { if: -> { brave_publisher_id.present? && brave_publisher_id_changed? && verified_publisher_exists? } }

  validate :youtube_channel_not_changed_once_initialized
  validates_uniqueness_of :youtube_channel_id, if: -> { youtube_channel_id.present? }

  # ensure that site publishers do not have oauth credentials (and vice versa)
  validates :brave_publisher_id, absence: true, if: -> { auth_user_id.present? }
  validates :auth_user_id, absence: true, if: -> { brave_publisher_id.present? }

  # ensure that site publishers do not mix:
  # - normalized and unnormalized domains
  # - normalized domains and domain-related errors
  validates :brave_publisher_id, absence: true, if: -> { brave_publisher_id_error_code.present? || brave_publisher_id_unnormalized.present? }

  # clear/register domain errors as appropriate
  before_validation :clear_brave_publisher_id_error, if: -> { brave_publisher_id_unnormalized.present? && brave_publisher_id_unnormalized_changed? }
  before_validation :register_brave_publisher_id_error, if: -> { brave_publisher_id_unnormalized.present? && brave_publisher_id_error_code.present? }

  after_validation :generate_verification_token, if: -> { brave_publisher_id.present? && brave_publisher_id_changed? }

  before_destroy :dont_destroy_verified_publishers

  belongs_to :youtube_channel

  scope :created_recently, -> { where("created_at > :start_date", start_date: 1.week.ago) }

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

  # API call to eyeshade
  def wallet
    return @_wallet if @_wallet

    @_wallet = PublisherWalletGetter.new(publisher: self).perform

    # if the wallet call fails the wallet will be nil
    if @_wallet
      # Reset the uphold_verified if eyeshade thinks we need to re-authorize (or authorize for the first time)
      save_needed = false
      if self.uphold_verified && ['re-authorize', 'authorize'].include?(@_wallet.status['action'])
        self.uphold_verified = false
        save_needed = true
      end

      # Initialize the default_currency from the wallet, if it exists
      if self.default_currency.nil?
        default_currency_code = @_wallet.try(:wallet_details).try(:[], 'preferredCurrency')
        if default_currency_code
          self.default_currency = default_currency_code
          save_needed = true
        end
      end

      save! if save_needed
    end
    @_wallet
  end

  def encryption_key
    Publisher.encryption_key
  end

  def publication_title
    case publication_type
    when :site
      brave_publisher_id
    when :youtube_channel
      youtube_channel.title
    end
  end

  def to_s
    publication_title
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

  def uphold_complete?
    # check the wallet to see if the connection to uphold has been been denied
    action = wallet.try(:status).try(:[], 'action')
    if action == 're-authorize' || action == 'authorize'
      false
    else
      self.uphold_verified || self.uphold_access_parameters.present?
    end
  end

  def uphold_status
    if self.uphold_verified
      :verified
    elsif self.uphold_access_parameters.present?
      :access_parameters_acquired
    elsif self.uphold_code.present?
      :code_acquired
    else
      :unconnected
    end
  end

  def set_uphold_updated_at
    self.uphold_updated_at = Time.now
  end

  def publication_type
    if self.brave_publisher_id.present?
      :site
    elsif self.youtube_channel_id.present?
      :youtube_channel
    else
      :unselected
    end
  end

  def owner_identifier
    return nil if auth_user_id.blank?
    "oauth#google:#{auth_user_id}"
  end

  def brave_publisher_id_error_description
    case self.brave_publisher_id_error_code.to_sym
    when :exclusion_list_error
      I18n.t("activerecord.errors.models.publisher.attributes.brave_publisher_id.exclusion_list_error")
    when :api_error_cant_normalize
      I18n.t("activerecord.errors.models.publisher.attributes.brave_publisher_id.api_error_cant_normalize")
    when :invalid_uri
      I18n.t("activerecord.errors.models.publisher.attributes.brave_publisher_id.invalid_uri")
    when :taken
      I18n.t("activerecord.errors.models.publisher.attributes.brave_publisher_id.taken")
    else
      raise "Unrecognized brave_publisher_id_error_code: #{self.brave_publisher_id_error_code}"
    end
  end

  private

  def generate_verification_token
    update_attribute(:verification_token, PublisherTokenRequester.new(publisher: self).perform)
  end

  def clear_brave_publisher_id_error
    self.brave_publisher_id_error_code = nil
  end

  def register_brave_publisher_id_error
    self.errors.add(
      :brave_publisher_id_unnormalized,
      self.brave_publisher_id_error_description
    )
  end

  def verified_publisher_exists?
    self.class.where(brave_publisher_id: brave_publisher_id, verified: true).any?
  end

  # verification to ensure youtube_channel is not changed
  def youtube_channel_not_changed_once_initialized
    return if youtube_channel_id_was.nil?

    if youtube_channel_id_was != youtube_channel_id
      errors.add(:youtube_channel_id, "can not change once initialized")
    end
  end

  def self.youtube_channel_in_use(id)
    self.where(youtube_channel_id: id).count > 0
  end

  def dont_destroy_verified_publishers
    throw :abort if verified?
  end

  class << self
    def encryption_key
      Rails.application.secrets[:attr_encrypted_key]
    end
  end
end
