module Publishers
  class CryptoAddressesController < ApplicationController
    before_action :authenticate_publisher!

    def index
      @crypto_addresses = CryptoAddress.where(publisher_id: current_publisher.id)
      render(json: @crypto_addresses)
    end

    def destroy
      begin
        @crypto_address = current_publisher.crypto_addresses.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        return render json: {}, status: 404
      end

      success = @crypto_address.destroy

      respond_to do |format|
        format.json {
          if success
            head :no_content
          else
            render(json: {errors: @crypto_address.errors}, status: 400)
          end
        }
      end
    end
  end
end
