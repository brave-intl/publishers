class Publisher < ApplicationRecord
  has_paper_trail

  has_many :statements, -> { order('created_at DESC') }, class_name: 'PublisherStatement'

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

  # TODO: Show user normalized domain before they commit
  before_validation :normalize_inspect_brave_publisher_id, if: -> { brave_publisher_id.present? && brave_publisher_id_changed?}
  after_validation :generate_verification_token, if: -> { brave_publisher_id.present? && brave_publisher_id_changed? }

  before_destroy :dont_destroy_verified_publishers

  belongs_to :youtube_channel

  scope :created_recently, -> { where("created_at > :start_date", start_date: 1.week.ago) }

  # API call to eyeshade
  def wallet
    return @_wallet if @_wallet

    @_wallet = PublisherWalletGetter.new(publisher: self).perform

    # if the wallet call fails the wallet will be nil
    if @_wallet
      # Reset the uphold_verified if eyeshade thinks we need to re-authorize (or authorize for the first time)
      save_needed = false
      if self.uphold_verified && @_wallet.status['action'] == 're-authorize'
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
    Rails.application.secrets[:attr_encrypted_key]
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

  def inspect_brave_publisher_id
    require "faraday"
    result = PublisherHostInspector.new(brave_publisher_id: self.brave_publisher_id).perform
    if result[:host_connection_verified]
      self.supports_https = result[:https]
      self.detected_web_host = result[:web_host]
      self.host_connection_verified = true
    else
      self.supports_https = false
      self.detected_web_host = nil
      self.host_connection_verified = false
    end
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

  private

  def generate_verification_token
    update_attribute(:verification_token, PublisherTokenRequester.new(publisher: self).perform)
  end

  def normalize_inspect_brave_publisher_id
    normalize_brave_publisher_id
    inspect_brave_publisher_id unless errors.any?
  end

  def normalize_brave_publisher_id
    require "faraday"
    self.brave_publisher_id = PublisherDomainNormalizer.new(domain: brave_publisher_id).perform
  rescue PublisherDomainNormalizer::DomainExclusionError
    errors.add(
      :brave_publisher_id,
      "#{I18n.t('activerecord.errors.models.publisher.attributes.brave_publisher_id.exclusion_list_error')} #{Rails.application.secrets[:support_email]}"
    )
  rescue PublisherDomainNormalizer::OfflineNormalizationError => e
    errors.add(:brave_publisher_id, e.message)
  rescue Faraday::Error
    errors.add(
      :brave_publisher_id,
      I18n.t("activerecord.errors.models.publisher.attributes.brave_publisher_id.api_error_cant_normalize")
    )
  rescue URI::InvalidURIError
    errors.add(
      :brave_publisher_id,
      I18n.t("activerecord.errors.models.publisher.attributes.brave_publisher_id.invalid_uri")
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
end
