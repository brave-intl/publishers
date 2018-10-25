class Admin::UnattachedPromoRegistrationsController < AdminController
  include PromosHelper

  def index
    filter = params[:filter]
    case filter
    when "All codes", nil, ""
      @promo_registrations = PromoRegistration.unattached.order("created_at DESC")
    when "Not assigned"
      @promo_registrations = PromoRegistration.unattached.where(promo_campaign_id: nil).order("created_at DESC")
    else
      @promo_registrations = PromoRegistration.joins(:promo_campaign).
                                               unattached.
                                               where(promo_campaigns: {name: filter}).
                                               order("created_at DESC")
    end
    @current_campaign = params[:filter] || "All codes"
    @campaigns = PromoCampaign.all.map {|campaign| campaign.name}
  end

  def create
    number = create_params.to_i
    if number > 50
      redirect_to admin_unattached_promo_registrations_path, alert: "Can't create more than 50 codes at a time."
    else
      PromoRegistrarUnattached.new(number: number).perform
      redirect_to admin_unattached_promo_registrations_path, notice: "#{number} codes created."
    end
  end

  def report
    referral_codes = params[:referral_codes]
    @reporting_interval = params[:reporting_interval]
    @event_types = params[:event_types]
    if @event_types.nil?
      return redirect_to admin_unattached_promo_registrations_path(filter: params[:filter]),
                        alert: "Please check at least one of downloads, installs, or confirmations."
    end
    
    report_start_and_end_date = parse_report_dates(params[:referral_code_report_period], @reporting_interval)
    report_info = PromoReportGenerator.new(referral_codes: referral_codes,
                                                  start_date: report_start_and_end_date[:start_date],
                                                  end_date: report_start_and_end_date[:end_date],
                                                  reporting_interval: @reporting_interval).perform

    @start_date = report_info["start_date"]
    @end_date = report_info["end_date"]
    @report_contents = report_info["contents"]

    report_string = render_to_string :layout => false
    send_data report_string, filename: "BraveReferralPromoReport.html", type: "application/html"
  end

  def update_statuses
    referral_codes = params[:referral_codes]
    referral_code_status = params[:referral_code_status]
    promo_registrations = PromoRegistration.where(referral_code: referral_codes)
    PromoUnattachedStatusUpdater.new(promo_registrations: promo_registrations, status: referral_code_status).perform
    redirect_to admin_unattached_promo_registrations_path(filter: params[:filter]),
                notice: "#{referral_codes.count} codes updated to '#{referral_code_status}' status."
  end

  def assign
    referral_codes = params[:referral_codes]
    promo_campaign_target = PromoCampaign.where(name: params[:promo_campaign_target]).first
    promo_registrations = PromoRegistration.where(referral_code: referral_codes)
    promo_registrations.update_all(promo_campaign_id: promo_campaign_target.id)
    redirect_to admin_unattached_promo_registrations_path(filter: params[:promo_campaign_target]),
                notice: "Assigned #{referral_codes.count} codes to campaign '#{params[:promo_campaign_target]}'."
  end

  private

  def parse_report_dates(report_period, reporting_interval)
    start_date = Date.new(report_period["start(1i)"].to_i,
                          report_period["start(2i)"].to_i,
                          report_period["start(3i)"].to_i)
    end_date = Date.new(report_period["end(1i)"].to_i,
                        report_period["end(2i)"].to_i,
                        report_period["end(3i)"].to_i)
    {
      start_date: start_date,
      end_date: end_date
    }
  end

  def create_params
    params.require(:number_of_codes_to_create)
  end
end