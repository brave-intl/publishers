class Admin::PayoutReportsController < AdminController
  def index
    @payout_reports = PayoutReport.all.order(created_at: :desc).paginate(page: params[:page])
  end

  def show
    @payout_report = PayoutReport.find(params[:id])
    render(json: @payout_report.contents, status: 200)
  end

  def download    
    @payout_report = PayoutReport.find(params[:id])
    @payout_report.update_report_contents
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
    EnqueuePublishersForPayoutJob.perform_later(final: params[:final].present?,
                                                should_send_notifications: params[:should_send_notifications].present?)
    
    redirect_to admin_payout_reports_path, flash: { notice: "Your payout report is being generated, check back soon." }
  end

  private

  def assign_authority(report_contents)
    report_contents = JSON.parse(report_contents)

    report_contents.each do |potential_payout|
      potential_payout["authority"] = current_publisher.email # Assigns authority to admin email
    end

    report_contents.to_json
  end
end
