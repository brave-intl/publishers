module ReferralPromo
  extend ActiveSupport::Concern
  include UserFeatureFlags

  included do
    MAX_PROMO_REGISTRATIONS = 500

    validates :promo_registrations, length: { maximum: MAX_PROMO_REGISTRATIONS }
    validates :promo_token_2018q1, uniqueness: true, allow_nil: true
  end

  def promo_status(promo_running)
    if !promo_running || promo_lockout_time_passed?
      :over
    elsif feature_flags[UserFeatureFlags::REFERRAL_ENABLED_OVERRIDE]
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

  # Public: Validates if the user's country is on the excluded list.
  #
  # Returns true or false depending on if the country is included.
  def valid_promo_country?
    PromoRegistration::RESTRICTED_COUNTRIES.exclude?(country)
  end

  def may_register_promo?
    # If the user doesn't have the referral_kyc_flag on then we can register them still.
    return true unless referral_kyc_required?

    # Otherwise they must be brave payable and from a valid country
    brave_payable? && valid_promo_country?
  end

  # Public: Enqueues a job which allows publishers referrals to work if they are payable and in a valid promo_country
  #
  # Returns nil
  def update_promo_status!
    return unless may_register_promo?

    Promo::UpdateStatus.perform_later(id: id, status: PublisherStatusUpdate::ACTIVE)
  end
end
