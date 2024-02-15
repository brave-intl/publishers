class Api::Nextv1::CryptoAddressesController < Api::Nextv1::BaseController
  include PublishersHelper

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

    begin
      @crypto_address.destroy!
      render(json: {crypto_address: true}, status: 200)
    rescue => e
      LogException.perform(e, publisher: current_publisher)
      render(json: {errors: "address could not be deleted"}, status: 400)
    end
  end
end
