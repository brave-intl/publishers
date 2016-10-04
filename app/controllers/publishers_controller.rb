class PublishersController < ApplicationController
  before_action :authenticate_publisher!,
                only: %i(current payment_info update_payment_info)

  def new
    @publisher = Publisher.new
  end

  def create
    @publisher = Publisher.new(publisher_create_params)
    if @publisher.save
      sign_in(:publisher, @publisher)
      redirect_to payment_info_publishers_path
    else
      render :new, alert: "some errors with the submission"
    end
  end

  # Payment info == BTC address and tax info
  def payment_info
    @publisher = current_publisher
  end

  def update_payment_info
    @publisher = current_publisher
    @publisher.assign_attributes(publisher_payment_update_params)
    if @publisher.save
      redirect_to current_publishers_path
    else
      render :payment_info, alert: "some errors with the submission"
    end
  end

  # Testing only
  def current
  end

  private

  def publisher_create_params
    params.require(:publisher).permit(:email, :base_domain, :name, :phone)
  end

  def publisher_payment_update_params
    params.require(:publisher).permit(:bitcoin_address)
  end
end
