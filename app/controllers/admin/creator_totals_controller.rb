module Admin
  class CreatorTotalsController < AdminController
    before_action :set_creator_total, only: :update

    def index
      @creator_totals = CreatorTotals.paginate(page: params[:page]).order(created_at: :desc)
      if params[:search]
        @creator_totals = @creator_totals.where(publisher_id: params[:search])
      end
    end

    def update
      if @creator_total.update(creator_total_params)
        redirect_to admin_creator_totals_path, notice: "Updated successfully."
      else
        redirect_to admin_creator_totals_path, alert: "Update failed."
      end
    end

    private

    def set_creator_total
      @creator_total = CreatorTotals.find(params[:id])
    end

    def creator_total_params
      params.require(:creator_totals).permit(:paid)
    end
  end
end
