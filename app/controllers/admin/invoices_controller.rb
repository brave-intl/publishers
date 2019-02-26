module Admin
  class InvoicesController < AdminController
    def show
      @invoice = Invoice.find(params[:id])
    end

    def new
      @invoice = Invoice.new(partner_id: params[:partner_id])
    end

    def create
      date_string = "#{params[:invoice][:month]}-#{params[:invoice][:year]}"
      date = DateTime.strptime(date_string, "%m-%Y").utc

      @invoice = Invoice.new(invoice_params.merge(partner_id: params[:partner_id], date: date))

      if @invoice.save
        redirect_to [:admin, @invoice.partner, @invoice]
      else
        render "new"
      end
    end

    def edit
      @invoice = load_invoice
    end

    def finalize
      @invoice = load_invoice
    end

    def update_status
      @invoice = load_invoice
      @invoice.update(status: Invoice::IN_PROGRESS, finalized_by: current_user)

      redirect_to [:admin, @invoice.partner, @invoice], flash: { notice: "Invoice has been marked as 'In Progress'" }
    end

    def update
      @invoice = load_invoice

      if @invoice.update(invoice_params)
        redirect_to [:admin, :partner, @invoice]
      else
        render "edit"
      end
    end

    def upload
      @invoice = load_invoice

      invoice_file = InvoiceFile.new(
        invoice_id: @invoice.id,
        uploaded_by: current_publisher,
        file: params[:file]
      )

      path = admin_partner_invoice_path(
        partner_id: params[:partner_id],
        id: @invoice.id
      )

      if params[:file].present? && invoice_file.save
        PartnerMailer.invoice_file_added(invoice_file, @invoice.partner).deliver_later
        redirect_to path, flash: { notice: "Your document was uploaded successfully" }
      else
        redirect_to path, flash: { alert: "Your document could not be uploaded" }
      end
    end

    private

    def load_invoice
      invoice = Invoice.includes(:partner).find(params[:id] || params[:invoice_id])
      raise Invoice::ReadOnlyError unless invoice.pending?

      invoice
    end

    def invoice_params
      params.require(:invoice).permit(:finalized_amount)
    end
  end
end
