module Admin
  class PaymentsController < AdminController
    include PromosHelper
    include PublishersHelper
    def index
      publisher = Publisher.find(params[:publisher_id])
      @navigation_view = Views::Admin::NavigationView.new(publisher).as_json.merge({ navbarSelection:"Payments"}).to_json

      respond_to do |format|
        format.html do
          @data = Views::Admin::NavigationView.new(publisher).as_json
        end
        format.json do
          render json: Views::Admin::PaymentView.new(publisher: publisher).as_json
        end
      end
    end
  end
end
