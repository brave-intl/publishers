module Admin
  class ReferralTotalsController < AdminController
    before_action :set_referral_total, only: :update

    def index
      @referral_totals = ReferralTotals.paginate(page: params[:page]).order(created_at: :desc)
      if params[:search]
        @referral_totals = @referral_totals.where(publisher_id: params[:search])
      end
    end

    def update
      if @referral_total.update(referral_total_params)
        redirect_to admin_referral_totals_path, notice: "Updated successfully."
      else
        redirect_to admin_referral_totals_path, alert: "Update failed."
      end
    end

    private

    def set_referral_total
      @referral_total = ReferralTotals.find(params[:id])
    end

    def referral_total_params
      params.require(:referral_totals).permit(:paid)
    end
  end
end
