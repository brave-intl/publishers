module UserFeatureFlags
  include ActiveSupport::Concern
  WIRE_ONLY = "wire_only".freeze

  def wire_only?
    feature_flags[WIRE_ONLY].present?
  end
end
