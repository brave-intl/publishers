module Publishers
  class CryptoAddressesController < ApplicationController
    before_action :authenticate_publisher!

    def index
      @crypto_addresses = CryptoAddress.where(publisher_id: current_publisher.id)
      render(json: @crypto_addresses)
    end

    def destroy
      @crypto_address = current_publisher.crypto_addresses.find(params[:id])
      success = (@crypto_address.publisher_id == current_publisher.id) ? @crypto_address.destroy : false

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
