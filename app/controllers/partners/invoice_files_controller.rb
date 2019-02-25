module Partners
  class InvoiceFilesController < ApplicationController
    before_action :filter_users

    def create
      invoice = Invoice.find(params[:invoice_id])
      raise unless invoice.pending?
      raise unless invoice_access?(invoice)

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
      raise unless invoice_access?(invoice_file.invoice)

      invoice_file.update(archived: true)

      files = invoice_file.active_files
      render json: { files: files.as_json.compact }
    end

    private

    def invoice_access?(invoice)
      current_publisher.admin? || current_publisher.id == invoice.partner_id
    end

    #Internal: only allow partners to access this UI
    #
    # Returns nil
    def filter_users
      raise unless current_user&.partner?
    end
  end
end
