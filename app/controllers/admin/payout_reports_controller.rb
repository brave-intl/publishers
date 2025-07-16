# typed: ignore

class Admin::PayoutReportsController < AdminController
  def index
    flash[:alert] = "Payouts stopped in February 2025.  This is a legacy page to review old reports."
    @payout_reports = PayoutReport.all.order(created_at: :desc).paginate(page: params[:page])
  end

  def show
    @payout_report = PayoutReport.find(params[:id])
    @previous_report = PayoutReport.where(
      manual: @payout_report.manual,
      final: @payout_report.final
    ).where("created_at < ?", @payout_report.created_at).order(created_at: :desc).take
  end
end
