# typed: false

module ReferralPromo
  extend ActiveSupport::Concern
  include UserFeatureFlags

  included do
    MAX_PROMO_REGISTRATIONS = 500 # standard:disable Lint/ConstantDefinitionInBlock

    validates :promo_registrations, length: {maximum: MAX_PROMO_REGISTRATIONS}
    validates :promo_token_2018q1, uniqueness: true, allow_nil: true
  end

  def promo_status(promo_running)
    if !promo_running || promo_lockout_time_passed?
      :over
    elsif may_create_referrals?
      :active
    else
      :inactive
    end
  end

  # Public: Validates that the Promos have not exceeded their lockout
  #
  # Returns a boolean determining if the user's promos can still be used
  def promo_lockout_time_passed?
    return promo_lockout_time < DateTime.now if promo_lockout_time.present?
    false
  end
end
