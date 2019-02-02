class InvoicesController < ApplicationController
  def index
    @invoices = Invoice
      .with_attached_file
      .joins(:file_attachment)
      .where(partner: current_publisher)
      .order(created_at: :desc)

    @invoices = { invoices: @invoices }.to_json

    respond_to do |format|
      format.html
      format.json  { render json: @invoices }
    end
  end

  def create
    invoice = Invoice.new(partner: current_publisher.becomes(Partner), uploaded_by: current_publisher)
    invoice.save
    invoice.file.attach(params[:file])
    invoice.save
  end
end
