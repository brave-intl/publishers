class Admin::PayoutReportsController < AdminController
  MANUAL = "manual"

  def index
    @payout_reports = PayoutReport.all.order(created_at: :desc).paginate(page: params[:page])
  end

  def show
    @payout_report = PayoutReport.find(params[:id])
    @previous_report = PayoutReport.where(
      manual: @payout_report.manual,
      final: @payout_report.final
    ).where("created_at < ?", @payout_report.created_at).order(created_at: :desc).take


    # render(json: @previous_report, status: 200)
  end

  def download
    @payout_report = PayoutReport.find(params[:id])
    contents = assign_authority(@payout_report.contents)
    send_data contents,
      filename: "payout-#{@payout_report.created_at.strftime("%FT%H-%M-%S")}",
      type: :json
  end

  def refresh
    UpdatePayoutReportContentsJob.perform_later(payout_report_ids: [params[:id]])
    redirect_to admin_payout_reports_path, flash: { notice: "Refreshing report JSON.  Please try downloading in a couple minutes." }
  end

  def create
    EnqueuePublishersForPayoutJob.perform_later(final: params[:final].present?, manual: params[:manual].present?)
    redirect_to admin_payout_reports_path, flash: { notice: "Your payout report is being generated, check back soon." }
  end

  def notify
    EnqueuePublishersForPayoutNotificationJob.perform_later
    redirect_to admin_payout_reports_path, flash: { notice: "Sending notifications to publishers with disconnected wallets." }
  end

  def upload_settlement_report
    content = File.read(params[:file].tempfile)
    json = JSON.parse(content)

    Eyeshade::Publishers.new.create_settlement(body: json)

    json.each do |entry|
      next unless entry["type"] == MANUAL && entry["owner"] && entry["amount"]

      partner_id = entry["owner"].sub(Publisher::OWNER_PREFIX, "")

      invoice = Invoice.where(
        partner_id: partner_id,
        finalized_amount: entry["amount"],
        status: Invoice::IN_PROGRESS
      ).order(:created_at).first

      next unless invoice.present?

      invoice.update(
        payment_date: Date.today,
        status: Invoice::PAID,
        paid_by: current_publisher
      )
    end

    redirect_to admin_payout_reports_path, flash: { notice: "Successfully uploaded settlement report" }
  rescue JSON::ParserError => e
    redirect_to admin_payout_reports_path, flash: { alert: "Could not parse JSON. #{e.message}" }
  rescue Faraday::ClientError => eyeshade_error
    redirect_to admin_payout_reports_path, flash: { alert: "Eyeshade responded with a 400 🤷‍️" }
  end

  def toggle_payout_in_progress
    payout_status = Rails.cache.fetch('payout_in_progress')
    Rails.cache.write('payout_in_progress', !payout_status)
    redirect_to admin_payout_reports_path, flash: { alert: "Set 'payout in progress' to #{!payout_status}" }
  end

  private

  def assign_authority(report_contents)
    report_contents = JSON.parse(report_contents)
    report_contents.each do |potential_payout|
      # Assign current admin as authority, unless it is a manual report.
      potential_payout["authority"] = current_publisher.email unless potential_payout["type"] == PotentialPayment::MANUAL
    end

    report_contents.to_json
  end
end
