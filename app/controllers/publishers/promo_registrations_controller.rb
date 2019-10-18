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

  def overview
    start_date = (params[:month]&.to_date || Date.today).at_beginning_of_month
    end_date = start_date.at_end_of_month

    aggregate_stats = PromoRegistration.stats_for_registrations(
      promo_registrations: current_publisher.promo_registrations,
      start_date: start_date,
      end_date: end_date
    )

    groups = Eyeshade::Referrals.new.groups
    statement = Eyeshade::Referrals.new.statement(publisher: current_publisher, start_date: start_date, end_date: end_date)

    groups.each do |group|
      group[:count] = statement.select { |s| s[:groupId] == group[:id] }.length
    end

    # TODO Remove this in November 2019
    groups << {
      id: SecureRandom.uuid,
      name: 'Previous Rate',
      amount: "5.00",
      currency: "USD",
      count: aggregate_stats[PromoRegistration::FINALIZED] - statement.length,
    }

    render json: {
      groups: groups,
      totals: aggregate_stats,
    }
  end
end
