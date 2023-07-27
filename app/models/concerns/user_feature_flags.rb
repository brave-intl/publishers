# typed: false

module UserFeatureFlags
  extend ActiveSupport::Concern
  DAILY_EMAILS_FOR_PROMO_STATS = :daily_emails_for_promo_stats
  WIRE_ONLY = :wire_only
  INVOICE = :invoice
  MERCHANT = :merchant
  PROMO_LOCKOUT_TIME = :promo_lockout_time
  # This flag will be set to "true" for all new publishers.
  # It enforces KYC to be present in order to create a new promo code
  REFERRAL_KYC_REQUIRED = :referral_kyc_required
  GEMINI_ENABLED = :gemini_enabled
  REFERRAL_ENABLED_OVERRIDE = :referral_enabled_override
  LOCATION_ENABLED = :location_enabled
  P2P_ENABLED = :p2p_enabled

  VALID_FEATURE_FLAGS = [
    DAILY_EMAILS_FOR_PROMO_STATS,
    WIRE_ONLY,
    INVOICE,
    MERCHANT,
    REFERRAL_KYC_REQUIRED,
    PROMO_LOCKOUT_TIME,
    GEMINI_ENABLED,
    REFERRAL_ENABLED_OVERRIDE,
    LOCATION_ENABLED,
    P2P_ENABLED
  ].freeze

  # Values stored in DAILY_EMAILS_FOR_PROMO_STATS
  DISABLED = "disabled".freeze
  PREVIOUS_DAY = "previous_day".freeze
  MONTH_TO_DATE = "month_to_date".freeze

  included do
    scope :daily_emails_for_promo_stats, -> {
      where("(feature_flags->'daily_emails_for_promo_stats')::jsonb ?| array['#{MONTH_TO_DATE}', '#{PREVIOUS_DAY}', 'true']")
    }
    scope :wire_only, -> { where("feature_flags->'#{WIRE_ONLY}' = 'true'") }
    scope :invoice, -> { where("feature_flags->'#{INVOICE}' = 'true'") }
    scope :merchant, -> { where("feature_flags->'#{MERCHANT}' = 'true'") }
    scope :gemini_enabled, -> { where("feature_flags->'#{GEMINI_ENABLED}' = 'true'") }
    scope :in_top_referrer_program, -> { where("feature_flags->'#{REFERRAL_ENABLED_OVERRIDE}' = 'true'") }
    scope :not_in_top_referrer_program, -> { where.not(id: in_top_referrer_program) }
    scope :p2p_enabled, -> { where("feature_flags->'#{P2P_ENABLED}' = 'true'") }
  end

  def update_feature_flags_from_form(update_flag_params)
    update_flag_params.keys.each do |flag_param_key|
      next unless flag_param_key.to_sym.in?(VALID_FEATURE_FLAGS)

      value = update_flag_params[flag_param_key]
      # If the field is a checkbox then we can cast it to a boolean
      # False is "0" and anything else is 0 for HTML forms
      if value == "0" || value.include?("checked")
        value = ActiveModel::Type::Boolean.new.cast(value)
      end

      if value.present?
        feature_flags[flag_param_key] = value
      else
        feature_flags.delete(flag_param_key)
      end
    end
    save!
  end

  def may_create_referrals?
    feature_flags.symbolize_keys[REFERRAL_ENABLED_OVERRIDE].present?
  end

  # Helper methods
  def wire_only?
    feature_flags.symbolize_keys[WIRE_ONLY].present?
  end

  def invoice?
    feature_flags.symbolize_keys[INVOICE].present?
  end

  def merchant?
    feature_flags.symbolize_keys[MERCHANT].present?
  end

  def referral_kyc_required?
    feature_flags.symbolize_keys[REFERRAL_KYC_REQUIRED].present?
  end

  def location_enabled?
    feature_flags.symbolize_keys[LOCATION_ENABLED].present?
  end

  def referral_kyc_not_required?
    !referral_kyc_required?
  end

  def gemini_enabled?
    feature_flags.symbolize_keys[GEMINI_ENABLED].present?
  end

  def has_daily_emails_for_promo_stats?
    feature_flags.symbolize_keys[DAILY_EMAILS_FOR_PROMO_STATS].present? && feature_flags.symbolize_keys[DAILY_EMAILS_FOR_PROMO_STATS] != DISABLED
  end

  def receives_mtd_promo_emails?
    feature_flags.symbolize_keys[DAILY_EMAILS_FOR_PROMO_STATS] == MONTH_TO_DATE
  end

  def allowed_to_create_referrals?
    feature_flags.symbolize_keys[REFERRAL_ENABLED_OVERRIDE].present?
  end

  def promo_lockout_time
    feature_flags.symbolize_keys[PROMO_LOCKOUT_TIME]
  end
end
