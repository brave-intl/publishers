module Admin
  class PaymentsController < AdminController
    include PromosHelper
    include PublishersHelper
    def show
      publisher = Publisher.find(params[:id])
      @navigation_view = Views::Admin::NavigationView.new(publisher).as_json.merge({ navbarSelection:"Payments"}).to_json

      respond_to do |format|
        format.html do
          publisher = Publisher.find(params[:id])
          @data = Views::Admin::PaymentView.new(publisher: publisher).as_json
        end
        format.json do
          publisher = Publisher.find(params[:id])
          render json: Views::Admin::PaymentView.new(publisher: publisher).as_json
        end
      end
    end
  end
end
