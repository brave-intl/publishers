class Admin::UnattachedPromoRegistrationsController < AdminController
  include PromosHelper

  def index
    promo_registrations = PromoRegistration.unattached_only.includes(:promo_campaign)

    if params[:referral_code].present?
      params[:filter] = promo_registrations.find_by(referral_code: params[:referral_code].strip)&.promo_campaign&.name
      flash[:alert] = "No campaigns found for #{params[:referral_code]}." if params[:filter].blank?
    end

    filter = params[:filter]
    case filter
    when "All codes", nil, ""
      @promo_registrations = promo_registrations.paginate(page: params[:page])
    when "Not assigned"
      @promo_registrations = promo_registrations.where(promo_campaign_id: nil).paginate(page: params[:page])
    else
      @promo_registrations = promo_registrations.where(promo_campaigns: { name: filter })
    end

    @promo_registrations = @promo_registrations.order("promo_registrations.created_at DESC")
    @current_campaign = params[:filter] || "All codes"
    @campaigns = PromoCampaign.pluck(:name).sort
  end

  def create
    codes = create_params[:number_of_codes_to_create].to_i

    campaign = PromoCampaign.find_or_create_by(name: create_params[:campaign_name])
    Promo::UnattachedRegistrar.new(number: codes, campaign: campaign).perform

    redirect_to admin_unattached_promo_registrations_path(filter: campaign.name), notice: "Sucessfully created #{codes} codes #{campaign.name}!"
  end

  def report
    referral_codes = params[:referral_codes]
    break_down_by_country = params[:geo].present?
    start_date, end_date = parse_report_dates

    GenerateReferralReportJob.perform_later(
      publisher_id: current_user.id,
      referral_codes: referral_codes,
      start_date: start_date,
      end_date: end_date,
      interval: params[:reporting_interval],
      break_down_by_country: break_down_by_country
    )

    redirect_to admin_unattached_promo_registrations_path(filter: params[:filter]),
      flash: { notice: "Generating the report, we'll email #{current_publisher.email} when it's done" }
  end

  def update_statuses
    referral_codes = params[:referral_codes]
    referral_code_status = params[:referral_code_status]
    promo_registrations = PromoRegistration.where(referral_code: referral_codes)
    Promo::UnattachedRegistrationStatusUpdater.new(promo_registrations: promo_registrations, status: referral_code_status).perform
    redirect_to admin_unattached_promo_registrations_path(filter: params[:filter]),
                notice: "#{referral_codes.count} codes updated to '#{referral_code_status}' status."
  end

  def assign_campaign
    referral_codes = params[:referral_codes]
    promo_campaign = PromoCampaign.find_by(name: params[:promo_campaign_target])

    PromoRegistration.where(referral_code: referral_codes).update_all(promo_campaign_id: promo_campaign&.id)

    redirect_to admin_unattached_promo_registrations_path(filter: promo_campaign&.name),
                notice: "Assigned #{referral_codes.count} codes to campaign '#{params[:promo_campaign_target]}'."
  end

  def assign_installer_type
    referral_codes = params[:referral_codes]
    installer_type = params[:installer_type]
    promo_registrations = PromoRegistration.where(referral_code: referral_codes)
    Promo::RegistrationInstallerTypeSetter.new(
      promo_registrations: promo_registrations,
      installer_type: installer_type
    ).perform
    redirect_to admin_unattached_promo_registrations_path(filter: params[:filter]),
                notice: "Assigned installer type '#{installer_type}' to #{referral_codes.count} codes."
  end

  private

  def parse_report_dates
    start_date = Date.parse(params[:start_date].values.join("-"))
    end_date = Date.parse(params[:end_date].values.join("-"))

    [start_date, end_date]
  end

  def create_params
    params.permit(:number_of_codes_to_create, :campaign_name)
  end
end
