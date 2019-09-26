module Publishers
  class StatementsController < ApplicationController
    before_action :authenticate_publisher!

    def index
      @uphold_connection = publisher.uphold_connection

      statement_contents = []
      @statement_has_content = statement_contents.length > 0

      respond_to do |format|
        format.html {}
        format.json {
          render json: Views::User::Statements.new(publisher: publisher)
        }
      end
    end

    def show
      overviews = Views::User::Statements.new(publisher: publisher, details_date: params[:id]).overviews
      @overview = overviews.detect { |x| x.earning_period == params[:id] }

      if params[:download]
        file_name = "#{@overview.name} - #{@overview.earning_period} statement"

        statement_string = render_to_string :layout => "statement"
        send_data statement_string, filename: file_name, type: "application/html"
      end

      render json: @overview
      # render layout: 'statement'
    end

    def statement
      statement_period = params[:statement_period]
      @transactions = PublisherStatementGetter.new(publisher: current_publisher, statement_period: statement_period).perform

      if @transactions.length == 0
        redirect_to statements_publishers_path, :flash => { :alert => t("publishers.statements.no_transactions") }
      else
        @statement_period = publisher_statement_period(@transactions)
        statement_file_name = publishers_statement_file_name(@statement_period)
        statement_string = render_to_string :layout => "statement"
        send_data statement_string, filename: statement_file_name, type: "application/html"
      end
    end


    def publisher
      return Publisher.find(params[:id]) if current_publisher.admin?
      current_publisher
    end
  end
end
