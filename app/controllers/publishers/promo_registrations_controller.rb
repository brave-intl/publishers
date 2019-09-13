class Publishers::PromoRegistrationsController < PublishersController
  def for_referral_code
    promo_registration =
      if current_publisher.admin?
        PromoRegistration.find_by(referral_code: params[:referral_code])
      else
        current_publisher.promo_registrations.find_by(referral_code: params[:referral_code])
      end
    render :unauthorized and return if promo_registration.nil?
    render json: promo_registration.stats_by_date.to_json
  end
end
