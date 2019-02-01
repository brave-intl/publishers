class InvoicesController < ApplicationController
  def index
    @invoices = { invoices: [] }.to_json

    respond_to do |format|
      format.html
      format.json  { render json: @reports }
    end
  end

  def create
    # report = Report.new(partner: current_publisher.becomes(Partner), uploaded_by: current_publisher)
    # report.save
    # report.file.attach(params[:file])
    # report.save
  end
end
