module Publishers
  class StatementsController < ApplicationController
    before_action :authenticate_publisher!

    ORIGINAL_GROUP_ID = "71341fc9-aeab-4766-acf0-d91d3ffb0bfa".freeze
    ORIGINAL_GROUP = { id: ORIGINAL_GROUP_ID, name: "Previous Group", amount: "5.0", currency: "USD" }.freeze

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
      overviews = Views::User::Statements.new(publisher: publisher).overviews
      @overview = overviews.detect { |x| x.earning_period.strip == params[:id] }
    end

    def rate_card
      start_date, end_date = earning_period

      groups = Eyeshade::Referrals.new.groups.push(ORIGINAL_GROUP)
      statement = Eyeshade::Referrals.new.statement(publisher: publisher, start_date: start_date, end_date: end_date)

      rate_cards = Views::User::RateCards.new(statement, groups)

      render json: rate_cards
    end

    private

    def earning_period
      period = params[:earning_period]

      period.split('-').map(&:strip).map(&:to_date)
    end

    def publisher
      return Publisher.find(params[:id]) if current_publisher.admin?
      current_publisher
    end
  end
end
