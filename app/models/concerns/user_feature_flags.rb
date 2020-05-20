module UserFeatureFlags
  extend ActiveSupport::Concern
  WIRE_ONLY = :wire_only
  INVOICE = :invoice
  MERCHANT = :merchant

  # This flag will be set to "true" for all new publishers.
  # It enforces KYC to be present in order to create a new promo code
  REFERRAL_KYC_REQUIRED = :REFERRAL_KYC_REQUIRED

  VALID_FEATURE_FLAGS = [
    WIRE_ONLY,
    INVOICE,
    MERCHANT,
    REFERRAL_KYC_REQUIRED
  ].freeze

  included do
    # Define scopes for each of the feature flags.
    # The result is that consumers can filter down publishers to a specific feature flag
    #
    # Example:
    #   Publisher.wire_only
    #
    # This scope would return all the publishers who have that flag enabled.
    VALID_FEATURE_FLAGS.each do |flag|
      scope flag, -> { where(feature_flags: { flag => true}) }
    end
  end

  def update_feature_flags_from_form(update_flag_params)
    update_flag_params.keys.each do |flag_param_key|
      next unless flag_param_key.to_sym.in?(VALID_FEATURE_FLAGS)
      # False is "0" and anything else is 0 for HTML forms
      checked = update_flag_params[flag_param_key] != "0"
      if checked.present?
        feature_flags[flag_param_key] = true
      else
        feature_flags.delete(flag_param_key)
      end
    end
    save!
  end

  # This helper methods for each of the feature flags
  # For example this generates a following method
  #
  #   def wire_only?
  #     feature_flags.symbolize_keys[WIRE_ONLY].present?
  #   end
  #
  # This is useful for methods that are checking if a feature is enbaled for a specific user.
  VALID_FEATURE_FLAGS.each do |flag|
    define_method :"#{flag}?" do
      feature_flags.symbolize_keys[flag].present?
    end
  end
end
