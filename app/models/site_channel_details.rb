class SiteChannelDetails < BaseChannelDetails
  has_paper_trail

  # brave_publisher_id is a normalized identifier provided by eyeshade API
  # It is like base domain (eTLD + left part) but may include additional
  # formats to support more publishers.
  # - normalized and unnormalized domains
  # - normalized domains and domain-related errors
  validates :brave_publisher_id, absence: true, if: -> { !errors.include?(:brave_publisher_id_unnormalized) && brave_publisher_id_unnormalized.present? }
  validate :brave_publisher_id_not_changed_once_initialized

  VERIFICATION_METHODS = %w(dns_record public_file github wordpress).freeze
  validates :verification_method, allow_blank: true, inclusion: { in: VERIFICATION_METHODS }

  class VerificationTokenValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      unless value =~ /\A[a-z0-9]{64}\z/i
        record.errors[attribute] << (options[:message] || "is not a valid verification token with 64 hex digits")
      end
    end
  end
  validates :verification_token, allow_blank: true, verification_token: true

  before_validation :register_brave_publisher_id_error, if: -> { brave_publisher_id_error_code.present? }

  # clear/register domain errors as appropriate
  before_validation :clear_brave_publisher_id_error, if: -> { brave_publisher_id_unnormalized.present? && brave_publisher_id_unnormalized_changed? }

  scope :recent_unverified_site_channels, -> (max_age: 6.weeks) {
    joins(:channel)
        .where.not(brave_publisher_id: SiteChannelDetails.joins(:channel).select(:brave_publisher_id).distinct.where("channels.verified": true))
        .where("channels.created_at": max_age.ago..Time.now)
  }

  scope :recent_ready_to_verify_site_channels, -> (max_age: 6.weeks) {
    joins(:channel)
        .where.not(
          brave_publisher_id: SiteChannelDetails
                              .joins(:channel)
                              .select(:brave_publisher_id)
                              .distinct
                              .where("channels.verified": true)
        )
        .where.not(verification_method: nil)
        .where("channels.updated_at": max_age.ago..Time.now)
  }

  def initialized?
    brave_publisher_id.present? || brave_publisher_id_unnormalized.present?
  end

  def publication_title
    brave_publisher_id || brave_publisher_id_unnormalized
  end

  def channel_identifier
    brave_publisher_id
  end

  # Unused for Site Channels
  def authorizer_email
    nil
  end

  # Unused for Site Channels
  def authorizer_name
    nil
  end

  def brave_publisher_id_error_description
    case self.brave_publisher_id_error_code.to_sym
      when :taken
        I18n.t("activerecord.errors.models.site_channel_details.attributes.brave_publisher_id.taken")
      when :exclusion_list_error
        I18n.t("activerecord.errors.models.site_channel_details.attributes.brave_publisher_id.exclusion_list_error")
      when :api_error_cant_normalize
        I18n.t("activerecord.errors.models.site_channel_details.attributes.brave_publisher_id.api_error_cant_normalize")
      when :invalid_uri
        I18n.t("activerecord.errors.models.site_channel_details.attributes.brave_publisher_id.invalid_uri")
      else
        raise "Unrecognized brave_publisher_id_error_code: #{self.brave_publisher_id_error_code}"
    end
  end

  def inspect_host
    return unless brave_publisher_id

    result = SiteChannelHostInspector.new(brave_publisher_id: self.brave_publisher_id).perform
    self.supports_https = result[:https].present?
    self.detected_web_host = result[:web_host]
    self.host_connection_verified = result[:host_connection_verified]
    self.https_error = result[:https_error]
  end

  def url
    "https://#{brave_publisher_id}"
  end

  private

  def clear_brave_publisher_id_error
    self.brave_publisher_id_error_code = nil
  end

  def register_brave_publisher_id_error
    self.errors.add(
        :brave_publisher_id_unnormalized,
        self.brave_publisher_id_error_description
    )
  end

  # verification to ensure brave_publisher_id is not changed
  def brave_publisher_id_not_changed_once_initialized
    return if brave_publisher_id_was.nil?

    if brave_publisher_id_was != brave_publisher_id
      errors.add(:brave_publisher_id, "can not change once initialized")
    end
  end
end
