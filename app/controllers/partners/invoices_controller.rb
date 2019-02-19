module Partners
  class InvoicesController < ApplicationController
    before_action :filter_users

    def index
      @invoices = Invoice
                  .where(partner: current_publisher)
                  .order(created_at: :desc)

      @invoices = { invoices: @invoices }.to_json

      render json: @invoices
    end

    def show
      @invoice = { invoice: find_invoice }.to_json
    end

    def update
      invoice = find_invoice
      raise Invoice::ReadOnlyError unless invoice.pending?

      invoice.amount = params[:amount]

      if invoice.save
        render json: invoice
      else
        render json: { errorText: invoice.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def find_invoice
      date = DateTime.strptime(params[:id], Invoice::URL_DATE_FORMAT).utc

      @invoice = Invoice
                 .includes(:invoice_files)
                 .find_by(partner: current_publisher, date: date)
    end

    # Internal: only allow partners to access this UI
    #
    # Returns nil
    def filter_users
      raise unless current_user&.partner?
    end
  end
end
