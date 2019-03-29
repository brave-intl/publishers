module Admin
  class ChannelTransfersController < AdminController
    def index
      @transfers = ChannelTransfer.paginate(page: params[:page]).order(created_at: :desc)
    end

    def show
      @publisher = Publisher.find(params[:id])
      @transfers = ChannelTransfer.where(transfer_from: @publisher).or(
        ChannelTransfer.where(transfer_to: @publisher)
      ).order(created_at: :desc)
    end
  end
end
