module UserFeatureFlags
  extend ActiveSupport::Concern
  WIRE_ONLY = :wire_only
  INVOICE = :invoice
  MERCHANT = :merchant
  PROMO_EXPIRATION_TIME = :promo_expiration_time
  # This flag will be set to "true" for all new publishers.
  # It enforces KYC to be present in order to create a new promo code
  REFERRAL_KYC_REQUIRED = :referral_kyc_required

  VALID_FEATURE_FLAGS = [
    WIRE_ONLY,
    INVOICE,
    MERCHANT,
    REFERRAL_KYC_REQUIRED,
    PROMO_EXPIRATION_TIME,
  ].freeze

  included do
    scope :wire_only, -> { where(feature_flags: { WIRE_ONLY => true }) }
    scope :invoice,   -> { where(feature_flags: { INVOICE => true }) }
    scope :merchant,  -> { where(feature_flags: { MERCHANT => true }) }
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

      puts '🐱🐱🐱🐱🐱🐱🐱🐱🐱🐱'
      puts flag_param_key
      puts feature_flags[flag_param_key]

      if value.present?
        feature_flags[flag_param_key] = value
      else
        feature_flags.delete(flag_param_key)
      end
    end
    save!
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

  def referral_kyc_not_required?
    !referral_kyc_required?
  end

  def promo_expiration_time
    feature_flags.symbolize_keys[PROMO_EXPIRATION_TIME]
  end
end
