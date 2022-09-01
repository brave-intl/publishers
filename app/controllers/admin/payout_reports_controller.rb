# typed: ignore

class Admin::PayoutReportsController < AdminController
  MANUAL = "manual"

  def index
    flash[:alert] = "To view (1) expected vs actual potential payments, (2) payouts to be paid and their amounts, (3) or payments missing Uphold addresses, message Albert Wang for a query on Metabase until follower database is setup"
    @payout_reports = PayoutReport.all.order(created_at: :desc).paginate(page: params[:page])
  end

  def show
    @payout_report = PayoutReport.find(params[:id])
    @previous_report = PayoutReport.where(
      manual: @payout_report.manual,
      final: @payout_report.final
    ).where("created_at < ?", @payout_report.created_at).order(created_at: :desc).take
  end

  def edit
    @payout_report = PayoutReport.find(params[:id])
  end

  def update
    @payout_report = PayoutReport.find(params[:id])
    if @payout_report.update(payout_params)
      redirect_to admin_payout_report_path(@payout_report), flash: {notice: "Saved"}
    else
      redirect_to admin_payout_report_path(@payout_report), flash: {alert: "Could not save"}
    end
  end

  def create
    EnqueuePublishersForPayoutJob.perform_later(final: params[:final].present?, manual: params[:manual].present?)
    redirect_to admin_payout_reports_path, flash: {notice: "Your payout report is being generated, check back soon."}
  end

  def notify
    EnqueuePublishersForPayoutJob.perform_later(args: [EnqueuePublishersForPayoutJob::SEND_NOTIFICATIONS])
    redirect_to admin_payout_reports_path, flash: {notice: "Sending notifications to publishers with disconnected wallets."}
  end

  def upload_settlement_report
    content = File.read(params[:file].tempfile)
    json = JSON.parse(content)

    not_found = []

    json.each do |entry|
      next unless entry["type"] == MANUAL && entry["owner"] && entry["amount"]

      begin
        invoice = Invoice.find(entry.dig("documentId"))
      rescue ActiveRecord::RecordNotFound
        publisher_id = entry["owner"].sub(Publisher::OWNER_PREFIX, "")
        invoice = Invoice.where(
          publisher_id: publisher_id,
          finalized_amount: (entry["probi"].to_i / 1E18).round(2),
          status: Invoice::IN_PROGRESS
        ).order(:created_at).first
      end

      if invoice.blank?
        not_found << "#{entry.dig("publisher")} - transactionId: #{entry.dig("transactionId")}\n" if invoice.blank?
        next
      end

      invoice.update(
        payment_date: Date.today,
        status: Invoice::PAID,
        paid_by: current_publisher
      )
    end

    notice = "Successfully uploaded settlement report"
    notice += "Could not find #{not_found}" if not_found.present?

    redirect_to admin_payout_reports_path, flash: {notice: notice}
  rescue JSON::ParserError => e
    redirect_to admin_payout_reports_path, flash: {alert: "Could not parse JSON. #{e.message}"}
  rescue Faraday::ClientError
    redirect_to admin_payout_reports_path, flash: {alert: "Eyeshade responded with a 400 🤷‍️"}
  rescue => e
    Raven.capture_exception(e)
    redirect_to admin_payout_reports_path, flash: {alert: "Something bad happened! Please check Sentry for more details"}
  end

  def payouts_in_progress
    Rails.cache.write(SetPayoutsInProgressJob::PAYOUTS_IN_PROGRESS, payouts_in_progress_params)
    redirect_to admin_payout_reports_path, flash: {alert: "Set 'payout in progress' to #{payouts_in_progress_params}"}
  end

  private

  def payout_params
    params.require(:payout_report).permit(:final)
  end

  def payouts_in_progress_params
    params.require(:payout_in_progress)
      .permit(:paypal_connection,
        :bitflyer_connection,
        :uphold_connection,
        :gemini_connection).to_h.transform_values! { |v| v == "1" }
  end

  def assign_authority(report_contents)
    report_contents = JSON.parse(report_contents)
    report_contents.each do |potential_payout|
      # Assign current admin as authority, unless it is a manual report.
      potential_payout["authority"] = current_publisher.email unless potential_payout["type"] == PotentialPayment::MANUAL
    end

    report_contents.to_json
  end
end
