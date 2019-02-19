module Partners
  class InvoiceFilesController < ApplicationController
    before_action :filter_users

    def create
      invoice = Invoice.find(params[:invoice_id])
      raise unless invoice.pending?

      invoice_file = InvoiceFile.new(
        invoice_id: invoice.id,
        uploaded_by: current_publisher,
        file: params[:file]
      )

      invoice_file.save

      files = invoice_file.active_files
      render json: { files: files.as_json.compact }
    end

    def destroy
      invoice_file = InvoiceFile.find(params[:id])
      raise unless invoice_file.invoice.pending?

      invoice_file.update(archived: true)

      files = invoice_file.active_files
      render json: { files: files.as_json.compact }
    end

    #Internal: only allow partners to access this UI
    #
    # Returns nil
    def filter_users
      raise unless current_user&.partner?
    end
  end
end
