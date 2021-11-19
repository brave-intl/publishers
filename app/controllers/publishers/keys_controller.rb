# typed: false
module Publishers
  class KeysController < ApplicationController
    before_action :authenticate_publisher!
    before_action :authorize

    rescue_from Faraday::ClientError, with: :connection_error

    def index
      @keys = PaymentClient.key.all(publisher_id: current_publisher.id)
    end

    def create
      @key = PaymentClient.key.create(publisher_id: current_publisher.id, name: key_params[:name])
    end

    def roll
      PaymentClient.key.destroy(publisher_id: current_publisher.id, id: key_params[:key_id], seconds: key_params[:expiry].to_i)
      @key = PaymentClient.key.create(publisher_id: current_publisher.id, name: key_params[:name])
      render "create"
    end

    def destroy
      @key = PaymentClient.key.destroy(publisher_id: current_publisher.id, id: key_params[:id], seconds: 0)
      redirect_to keys_path, flash: {notice: t("publishers.keys.delete.success")}
    end

    private

    def authorize
      redirect_to root_url, flash: {alert: t("publishers.keys.shared.unauthorized")} unless current_user.merchant? || current_user.admin?
    end

    def connection_error(error)
      if error.response.dig(:status) == 429
        flash.now[:notice] = t("publishers.keys.shared.rate_limited")
      else
        flash.now[:notice] = t("publishers.keys.shared.error")
        Rails.logger.error(error)
      end
      render layout: "application"
    end

    def key_params
      params.permit(:id, :key_id, :name, :expiry)
    end
  end
end
