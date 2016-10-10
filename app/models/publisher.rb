class Publisher < ApplicationRecord
  has_one :legal_form, class_name: "PublisherLegalForm"

  attr_encrypted :bitcoin_address, key: :encryption_key
  attr_encrypted :authentication_token, key: :encryption_key

  devise :timeoutable, :trackable

  # Normalizes attribute before validation and saves into other attribute
  phony_normalize :phone, as: :phone_normalized, default_country_code: "US"

  validates :bitcoin_address, bitcoin_address: true, presence: true, if: :should_validate_bitcoin_address?
  validates :email, email: { strict_mode: true }, presence: true
  validates :name, presence: true
  validates :phone, phony_plausible: true

  # brave_publisher_id is a normalized identifier provided by ledger API
  # It is like base domain (eTLD + left part) but may include additional
  # formats to support more publishers.
  validates :brave_publisher_id, presence: true

  # TODO: Show user normalized domain before they commit
  before_validation :normalize_brave_publisher_id, if: -> { !persisted? }

  before_create :generate_authentication_token
  after_create :generate_verification_token


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

  def generate_authentication_token
    self.authentication_token = SecureRandom.hex(32)
  end

  def generate_verification_token
    update_attribute(:verification_token, PublisherTokenRequester.new(publisher: self).perform)
  end

  def normalize_brave_publisher_id
    require "faraday"
    self.brave_publisher_id = PublisherDomainNormalizer.new(domain: brave_publisher_id).perform
  rescue Faraday::Error
    errors.add(:brave_publisher_id, "can't be normalized because of an API error")
  end

  # This allows for blank bitcoin_address on first create, but
  # requires it on subsequent steps
  def should_validate_bitcoin_address?
    return false
    # TODO: After tax info setup
    persisted?
  end
end
