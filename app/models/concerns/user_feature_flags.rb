module UserFeatureFlags
  include ActiveSupport::Concern
  WIRE_ONLY = :wire_only

  VALID_FEATURE_FLAGS = [WIRE_ONLY].freeze

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

  def wire_only?
    feature_flags[WIRE_ONLY].present?
  end
end
