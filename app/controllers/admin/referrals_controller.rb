module Admin
  class ReferralsController < AdminController
    def index
      @transfers = ChannelTransfer.paginate(page: params[:page]).order(created_at: :desc)
    end

    def show
      @publisher = Publisher.find(params[:id])
      @promo_registrations = @publisher.promo_registrations
    end
  end
end
