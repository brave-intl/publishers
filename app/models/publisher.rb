class Publisher < ApplicationRecord
  has_paper_trail

  has_one :legal_form, class_name: "PublisherLegalForm"

  attr_encrypted :bitcoin_address, key: :encryption_key
  attr_encrypted :authentication_token, key: :encryption_key

  devise :timeoutable, :trackable

  # Normalizes attribute before validation and saves into other attribute
  phony_normalize :phone, as: :phone_normalized, default_country_code: "US"

  validates :bitcoin_address, bitcoin_address: true, if: :bitcoin_address_present_and_changed?
  validates :email, email: { strict_mode: true }, presence: true
  validates :name, presence: true
  validates :phone_normalized, phony_plausible: true

  # brave_publisher_id is a normalized identifier provided by ledger API
  # It is like base domain (eTLD + left part) but may include additional
  # formats to support more publishers.
  validates :brave_publisher_id,
    presence: true,
    uniqueness: { if: -> { !persisted? && verified_publisher_exists? } }

  # TODO: Show user normalized domain before they commit
  before_validation :normalize_brave_publisher_id, if: -> { !persisted? }
  before_create :generate_authentication_token
  after_create :generate_verification_token
  before_save :api_update_bitcoin_address,
    if: -> { bitcoin_address_present_and_changed? }

  scope :created_recently, -> { where("created_at > :start_date", start_date: 1.week.ago) }

  # API call to eyeshade
  def balance
    @_balance ||= PublisherBalanceGetter.new(publisher: self).perform
  end

  def encryption_key
    Rails.application.secrets[:attr_encrypted_key]
  end

  def legal_form_completed?
    legal_form && legal_form.completed?
  end

  def to_s
    brave_publisher_id
  end

  private

  def api_update_bitcoin_address
    wallet_setter = PublisherWalletSetter.new(
      bitcoin_address: bitcoin_address,
      publisher: self,
    )
    begin
      wallet_setter.perform
    rescue Faraday::Error
      errors.add(
        :bitcoin_address,
        I18n.t("activerecord.errors.models.publisher.attributes.bitcoin_address.api_error")
      )
      throw(:abort)
    end
  end

  def bitcoin_address_present_and_changed?
    bitcoin_address.present? && bitcoin_address_changed?
  end

  def generate_authentication_token
    self.authentication_token = SecureRandom.hex(32)
  end

  def generate_verification_token
    update_attribute(:verification_token, PublisherTokenRequester.new(publisher: self).perform)
  end

  def normalize_brave_publisher_id
    require "faraday"
    self.brave_publisher_id = PublisherDomainNormalizer.new(domain: brave_publisher_id).perform
  rescue PublisherDomainNormalizer::DomainExclusionError
    errors.add(
      :brave_publisher_id,
      "#{I18n.t('activerecord.errors.models.publisher.attributes.brave_publisher_id.exclusion_list_error')} #{Rails.application.secrets[:support_email]}"
    )
  rescue Faraday::Error
    errors.add(
      :brave_publisher_id,
      I18n.t("activerecord.errors.models.publisher.attributes.brave_publisher_id.api_error_cant_normalize")
    )
  end

  def verified_publisher_exists?
    self.class.where(brave_publisher_id: brave_publisher_id, verified: true).any?
  end
end
