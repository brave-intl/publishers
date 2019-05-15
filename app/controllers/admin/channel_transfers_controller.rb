module Admin
  class ChannelTransfersController < AdminController
    def index
      @transfers = ChannelTransfer.paginate(page: params[:page]).order(created_at: :desc)
    end

    def show
      @publisher = Publisher.find(params[:id])
      @navigation_view = Views::Admin::NavigationView.new(@publisher).as_json.merge({ navbarSelection:"Payments"}).to_json

      @transfers = ChannelTransfer.where(transfer_from: @publisher).or(
        ChannelTransfer.where(transfer_to: @publisher)
      ).order(created_at: :desc)
    end
  end
end
