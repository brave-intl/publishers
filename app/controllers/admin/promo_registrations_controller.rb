class Admin::PromoRegistrationsController < AdminController
    def for_referral_code
      publisher = Publisher.find(params[:publisher_id])
      promo_registration = publisher.promo_registrations.find_by(referral_code: params[:referral_code])
      render :unauthorized and return if promo_registration.nil?
      render json: promo_registration.stats_by_date.to_json
    end
end
  