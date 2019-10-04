module Publishers
  class StatementsController < ApplicationController
    before_action :authenticate_publisher!

    def index
      @uphold_connection = publisher.uphold_connection

      statement_contents = []
      @statement_has_content = statement_contents.length > 0

      respond_to do |format|
        format.html {}
        format.json { render json: Views::User::Statements.new(publisher: publisher) }
      end
    end

    def show
      overviews = Views::User::Statements.new(publisher: publisher, details_date: params[:id]).overviews
      @overview = overviews.detect { |x| x.earning_period == params[:id] }
    end

    private

    def publisher
      return Publisher.find(params[:id]) if current_publisher.admin?
      current_publisher
    end
  end
end
