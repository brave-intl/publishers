class Admin::Publishers::ReferralsController < Admin::PublishersController
  def show
    @publisher = Publisher.find(params[:id] || params[:publisher_id])
    @navigation_view = Views::Admin::NavigationView.new(publisher).as_json.merge({ navbarSelection: "Referrals" }).to_json
  end

  def stats_by_date
    promo_registration = current_publisher.promo_registrations.find_by(referral_code: params[:referral_code])
    render :unauthorized and return if promo_registration.nil?
    render json: promo_registration.stats_by_date.to_json
  end
end
