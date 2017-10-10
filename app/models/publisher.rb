class Publisher < ApplicationRecord
  has_paper_trail

  attr_encrypted :authentication_token, key: :encryption_key
  attr_encrypted :uphold_code, key: :encryption_key
  attr_encrypted :uphold_access_parameters, key: :encryption_key

  devise :timeoutable, :trackable

  # Normalizes attribute before validation and saves into other attribute
  phony_normalize :phone, as: :phone_normalized, default_country_code: "US"

  validates :email, email: { strict_mode: true }, presence: true, if: -> { brave_publisher_id.present? }
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
  validates :brave_publisher_id, uniqueness: { if: -> { brave_publisher_id_changed? && verified_publisher_exists? } }

  # TODO: Show user normalized domain before they commit
  before_validation :normalize_inspect_brave_publisher_id, if: -> { brave_publisher_id.present? && brave_publisher_id_changed?}
  after_validation :generate_verification_token, if: -> { brave_publisher_id && brave_publisher_id_changed? }

  scope :created_recently, -> { where("created_at > :start_date", start_date: 1.week.ago) }

  # API call to eyeshade
  def balance
    @_balance ||= PublisherBalanceGetter.new(publisher: self).perform
  end

  def encryption_key
    Rails.application.secrets[:attr_encrypted_key]
  end

  def to_s
    brave_publisher_id
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
    self.uphold_verified || self.uphold_access_parameters.present?
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
end
